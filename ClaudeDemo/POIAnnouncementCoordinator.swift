import Foundation
import Combine
import CoreLocation
import MapKit

/// Coordinator that manages periodic POI announcements based on user location
class POIAnnouncementCoordinator: ObservableObject {

    @Published var isEnabled = false
    @Published var lastAnnouncementTime: Date?

    private let searchService = POINearbySearchService()
    private let voiceManager = VoiceAnnouncementManager()

    private var timer: AnyCancellable?
    private var lastLocation: CLLocation?

    private let announcementInterval: TimeInterval = 30.0 // 30 seconds

    init() {
        print("[Coordinator] Initialized")
    }

    /// Start periodic announcements
    func start(with location: CLLocation) {
        guard !isEnabled else { return }

        print("[Coordinator] Starting periodic announcements")
        isEnabled = true
        lastLocation = location

        // Make first announcement immediately
        Task {
            await performAnnouncement(at: location)
        }

        // Setup timer for periodic announcements every 30 seconds
        timer = Timer.publish(every: announcementInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let location = self.lastLocation else { return }
                Task {
                    await self.performAnnouncement(at: location)
                }
            }
    }

    /// Stop periodic announcements
    func stop() {
        guard isEnabled else { return }

        print("[Coordinator] Stopping periodic announcements")
        isEnabled = false
        timer?.cancel()
        timer = nil
        voiceManager.stopAnnouncement()
    }

    /// Update user location for next announcement
    func updateLocation(_ location: CLLocation) {
        lastLocation = location
    }

    /// Perform a single POI announcement
    private func performAnnouncement(at location: CLLocation) async {
        print("[Coordinator] Performing announcement at: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        do {
            // Search for nearby POIs
            let pois = try await searchService.searchNearbyPOIs(near: location, radiusInMeters: 500)

            // Announce POIs
            await MainActor.run {
                voiceManager.announcePOIs(pois, from: location)
                lastAnnouncementTime = Date()
            }
        } catch {
            print("[Coordinator] Error during announcement: \(error.localizedDescription)")
        }
    }

    /// Toggle announcement feature on/off
    func toggle(at location: CLLocation?) {
        if isEnabled {
            stop()
        } else if let location = location {
            start(with: location)
        } else {
            print("[Coordinator] Cannot start: no location available")
        }
    }
}
