import Foundation
import MapKit
import CoreLocation

/// Service responsible for searching nearby Points of Interest using MapKit's local search
class POINearbySearchService {

    // Categories of POI to search for
    private let poiCategories = [
        "restaurant",
        "café",
        "pharmacie",
        "arrêt de bus",
        "boulangerie",
        "supermarché",
        "banque",
        "hôtel",
        "musée",
        "parc"
    ]

    /// Search for nearby POIs around a given location
    /// - Parameters:
    ///   - location: The center location to search from
    ///   - radiusInMeters: Search radius in meters (default: 500m)
    /// - Returns: Array of MKMapItem sorted by distance, limited to 5 items
    func searchNearbyPOIs(near location: CLLocation, radiusInMeters: CLLocationDistance = 500) async throws -> [MKMapItem] {
        print("[POI Search] Starting search near coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        var allPOIs: [MKMapItem] = []

        // Search for all POI categories
        for category in poiCategories {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = category
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: radiusInMeters * 2,
                longitudinalMeters: radiusInMeters * 2
            )
            request.resultTypes = .pointOfInterest

            let search = MKLocalSearch(request: request)

            do {
                let response = try await search.start()
                allPOIs.append(contentsOf: response.mapItems)
                print("[POI Search] Found \(response.mapItems.count) items for category: \(category)")
            } catch {
                print("[POI Search] Error searching for \(category): \(error.localizedDescription)")
            }
        }

        // Remove duplicates based on name and coordinate proximity
        allPOIs = removeDuplicates(from: allPOIs)

        // Calculate distances and sort
        let poisWithDistance = allPOIs.map { poi -> (item: MKMapItem, distance: CLLocationDistance) in
            let poiLocation = CLLocation(
                latitude: poi.placemark.coordinate.latitude,
                longitude: poi.placemark.coordinate.longitude
            )
            let distance = location.distance(from: poiLocation)
            return (item: poi, distance: distance)
        }

        // Filter by radius and sort by distance
        let filteredAndSorted = poisWithDistance
            .filter { $0.distance <= radiusInMeters }
            .sorted { $0.distance < $1.distance }
            .prefix(5)

        let result = filteredAndSorted.map { $0.item }

        print("[POI Search] Returning top \(result.count) POIs within \(radiusInMeters)m")
        for (index, poi) in result.enumerated() {
            let distance = filteredAndSorted[index].distance
            print("[POI Search] \(index + 1). \(poi.name ?? "Unknown") - \(Int(distance))m")
        }

        return result
    }

    /// Remove duplicate POIs based on name and coordinate proximity
    private func removeDuplicates(from items: [MKMapItem]) -> [MKMapItem] {
        var uniqueItems: [MKMapItem] = []

        for item in items {
            let isDuplicate = uniqueItems.contains { existing in
                // Check if same name
                guard let itemName = item.name?.lowercased(),
                      let existingName = existing.name?.lowercased(),
                      itemName == existingName else {
                    return false
                }

                // Check if coordinates are very close (within 10 meters)
                let itemLocation = CLLocation(
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
                let existingLocation = CLLocation(
                    latitude: existing.placemark.coordinate.latitude,
                    longitude: existing.placemark.coordinate.longitude
                )

                return itemLocation.distance(from: existingLocation) < 10
            }

            if !isDuplicate {
                uniqueItems.append(item)
            }
        }

        return uniqueItems
    }
}
