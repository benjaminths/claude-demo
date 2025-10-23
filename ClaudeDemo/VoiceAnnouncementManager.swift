import Foundation
import AVFoundation
import MapKit
import CoreLocation

/// Manager responsible for voice announcements using AVSpeechSynthesizer
class VoiceAnnouncementManager: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {

    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Announce a list of POIs with their distances from user location
    /// - Parameters:
    ///   - pois: Array of MKMapItem to announce
    ///   - userLocation: User's current location for distance calculation
    func announcePOIs(_ pois: [MKMapItem], from userLocation: CLLocation) {
        guard !pois.isEmpty else {
            print("[Voice] No POIs to announce")
            return
        }

        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        print("[Voice] Announcing \(pois.count) POIs")

        var announcements: [String] = []

        for (index, poi) in pois.enumerated() {
            let poiLocation = CLLocation(
                latitude: poi.placemark.coordinate.latitude,
                longitude: poi.placemark.coordinate.longitude
            )
            let distance = userLocation.distance(from: poiLocation)
            let distanceInMeters = Int(distance)

            // Get POI category name in French
            let category = getCategoryName(for: poi)

            // Format: "Restaurant Le Petit Lyonnais à 25 mètres"
            let name = poi.name ?? "Point d'intérêt"
            let announcement = "\(category) \(name) à \(distanceInMeters) mètres"

            announcements.append(announcement)
            print("[Voice] \(index + 1). \(announcement)")
        }

        // Combine all announcements with pauses
        let fullAnnouncement = announcements.joined(separator: ". ")

        // Create speech utterance in French
        let utterance = AVSpeechUtterance(string: fullAnnouncement)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        // Speak
        synthesizer.speak(utterance)
    }

    /// Get French category name for a POI
    private func getCategoryName(for poi: MKMapItem) -> String {
        guard let category = poi.pointOfInterestCategory else {
            return "Point d'intérêt"
        }

        switch category {
        case .restaurant:
            return "Restaurant"
        case .cafe:
            return "Café"
        case .store:
            return "Magasin"
        case .pharmacy:
            return "Pharmacie"
        case .bakery:
            return "Boulangerie"
        case .bank:
            return "Banque"
        case .hotel:
            return "Hôtel"
        case .museum:
            return "Musée"
        case .park:
            return "Parc"
        case .publicTransport:
            return "Transport public"
        case .gasStation:
            return "Station service"
        case .atm:
            return "Distributeur"
        case .hospital:
            return "Hôpital"
        case .school:
            return "École"
        case .library:
            return "Bibliothèque"
        case .theater:
            return "Théâtre"
        case .postOffice:
            return "Bureau de poste"
        case .airport:
            return "Aéroport"
        case .parking:
            return "Parking"
        case .fitnessCenter:
            return "Salle de sport"
        default:
            return "Point d'intérêt"
        }
    }

    /// Stop any ongoing speech
    func stopAnnouncement() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("[Voice] Speech started")
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("[Voice] Speech finished")
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("[Voice] Speech cancelled")
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}
