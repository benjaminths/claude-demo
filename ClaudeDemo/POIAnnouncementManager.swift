//
//  POIAnnouncementManager.swift
//  ClaudeDemo
//
//  Created by Benjamin on 24/10/2025.
//

import Foundation
import MapKit
import AVFoundation
import CoreLocation

class POIAnnouncementManager: NSObject, ObservableObject {
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var announcementTimer: Timer?
    var currentLocation: CLLocation?

    @Published var isAnnouncing = false
    @Published var lastAnnouncementText: String?

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }

    func startAnnouncements(location: CLLocation) {
        currentLocation = location
        isAnnouncing = true

        // Announce immediately
        announceNearbyPOIs()

        // Setup timer for 30 second intervals
        announcementTimer?.invalidate()
        announcementTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.announceNearbyPOIs()
        }
    }

    func stopAnnouncements() {
        isAnnouncing = false
        announcementTimer?.invalidate()
        announcementTimer = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    private func announceNearbyPOIs() {
        guard let location = currentLocation else { return }

        Task {
            let pois = await searchNearbyPOIs(around: location)
            let sortedPOIs = pois.sorted { poi1, poi2 in
                guard let loc1 = poi1.placemark.location,
                      let loc2 = poi2.placemark.location else {
                    return false
                }
                return location.distance(from: loc1) < location.distance(from: loc2)
            }

            // Take top 5 closest POIs
            let closestPOIs = Array(sortedPOIs.prefix(5))

            if closestPOIs.isEmpty {
                await MainActor.run {
                    lastAnnouncementText = "Aucun point d'intérêt trouvé à proximité"
                    speak(text: lastAnnouncementText!)
                }
                return
            }

            // Build announcement text
            var announcementParts: [String] = ["Points d'intérêt à proximité:"]

            for poi in closestPOIs {
                guard let poiLocation = poi.placemark.location else { continue }
                let distance = location.distance(from: poiLocation)
                let category = categoryName(for: poi.pointOfInterestCategory)
                let name = poi.name ?? "Lieu inconnu"

                let distanceText: String
                if distance < 1000 {
                    distanceText = "\(Int(distance)) mètres"
                } else {
                    distanceText = String(format: "%.1f kilomètres", distance / 1000)
                }

                announcementParts.append("\(category) \(name) à \(distanceText)")
            }

            let fullText = announcementParts.joined(separator: ". ")

            await MainActor.run {
                lastAnnouncementText = fullText
                speak(text: fullText)
            }

            print("📢 Voice Announcement: \(fullText)")
        }
    }

    private func searchNearbyPOIs(around location: CLLocation) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant café pharmacie hôpital banque magasin parc transport"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 500, // 500m radius
            longitudinalMeters: 500
        )

        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            return response.mapItems
        } catch {
            print("POI search error: \(error.localizedDescription)")
            return []
        }
    }

    private func speak(text: String) {
        speechSynthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        speechSynthesizer.speak(utterance)
    }

    private func categoryName(for category: MKPointOfInterestCategory?) -> String {
        guard let category = category else { return "Lieu" }

        switch category {
        case .restaurant: return "Restaurant"
        case .cafe: return "Café"
        case .hotel: return "Hôtel"
        case .store: return "Magasin"
        case .museum: return "Musée"
        case .park: return "Parc"
        case .theater: return "Théâtre"
        case .library: return "Bibliothèque"
        case .school: return "École"
        case .hospital: return "Hôpital"
        case .pharmacy: return "Pharmacie"
        case .bakery: return "Boulangerie"
        case .brewery: return "Brasserie"
        case .winery: return "Vignoble"
        case .gasStation: return "Station service"
        case .parking: return "Parking"
        case .postOffice: return "Bureau de poste"
        case .publicTransport: return "Transport public"
        case .airport: return "Aéroport"
        case .bank: return "Banque"
        case .atm: return "Distributeur"
        case .beach: return "Plage"
        case .campground: return "Camping"
        case .laundry: return "Laverie"
        case .movieTheater: return "Cinéma"
        case .nightlife: return "Vie nocturne"
        case .stadium: return "Stade"
        case .zoo: return "Zoo"
        default: return "Lieu"
        }
    }

    deinit {
        announcementTimer?.invalidate()
    }
}
