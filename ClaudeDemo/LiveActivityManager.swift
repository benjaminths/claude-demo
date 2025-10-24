//
//  LiveActivityManager.swift
//  ClaudeDemo
//
//  Created by Benjamin on 24/10/2025.
//

import Foundation
import ActivityKit
import CoreLocation
import MapKit

// POI Activity Attributes (must match the one in Widget Extension)
struct POIActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic properties
        var distance: Double // in meters
        var userLatitude: Double
        var userLongitude: Double
    }

    // Fixed properties about the POI
    var poiName: String
    var poiCategory: String
    var poiLatitude: Double
    var poiLongitude: Double
    var phoneNumber: String?
}

@available(iOS 16.1, *)
class LiveActivityManager: ObservableObject {
    @Published var currentActivity: Activity<POIActivityAttributes>?

    func startActivity(poi: MKMapItem, userLocation: CLLocation) {
        // Stop any existing activity
        stopActivity()

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }

        let poiCoordinate = poi.placemark.coordinate
        let poiLocation = CLLocation(latitude: poiCoordinate.latitude, longitude: poiCoordinate.longitude)
        let distance = userLocation.distance(from: poiLocation)

        let attributes = POIActivityAttributes(
            poiName: poi.name ?? "Point d'intérêt",
            poiCategory: categoryName(for: poi.pointOfInterestCategory),
            poiLatitude: poiCoordinate.latitude,
            poiLongitude: poiCoordinate.longitude,
            phoneNumber: poi.phoneNumber
        )

        let contentState = POIActivityAttributes.ContentState(
            distance: distance,
            userLatitude: userLocation.coordinate.latitude,
            userLongitude: userLocation.coordinate.longitude
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            print("✅ Live Activity started for: \(poi.name ?? "POI")")
        } catch {
            print("❌ Error starting Live Activity: \(error.localizedDescription)")
        }
    }

    func updateDistance(userLocation: CLLocation) {
        guard let activity = currentActivity else { return }

        let poiLocation = CLLocation(
            latitude: activity.attributes.poiLatitude,
            longitude: activity.attributes.poiLongitude
        )
        let distance = userLocation.distance(from: poiLocation)

        let updatedState = POIActivityAttributes.ContentState(
            distance: distance,
            userLatitude: userLocation.coordinate.latitude,
            userLongitude: userLocation.coordinate.longitude
        )

        Task {
            await activity.update(.init(state: updatedState, staleDate: nil))
            print("🔄 Live Activity distance updated: \(Int(distance))m")
        }
    }

    func stopActivity() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            print("🛑 Live Activity stopped")
        }
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
}
