//
//  MapView.swift
//  ClaudeDemo
//
//  Created by Benjamin on 23/10/2025.
//

import SwiftUI
import MapKit

extension MKMapItem: @retroactive Identifiable {
    public var id: String {
        return "\(placemark.coordinate.latitude),\(placemark.coordinate.longitude),\(name ?? "unknown")"
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var selection: MapSelection<MKMapItem>?
    @State private var selectedPOI: MKMapItem?
    @State private var hasInitiallyPositioned = false
    @Namespace private var mapScope

    var body: some View {
        ZStack {
            Map(position: $position, selection: $selection, scope: mapScope) {
                UserAnnotation()
            }
            .mapFeatureSelectionAccessory(.callout)
            .overlay(alignment: .topTrailing) {
                MapUserLocationButton(scope: mapScope)
                    .buttonBorderShape(.circle)
                    .padding(.top, 60)
                    .padding(.trailing, 16)
            }
            .mapScope(mapScope)
            .edgesIgnoringSafeArea(.all)
            .onChange(of: selection) { _, newSelection in
                handleMapSelection(newSelection)
            }
            .onChange(of: locationManager.location) { _, newLocation in
                if let location = newLocation, !hasInitiallyPositioned {
                    position = .region(MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))
                    hasInitiallyPositioned = true
                }
            }
            .sheet(item: $selectedPOI) { poi in
                POIDetailView(poi: poi)
                    .presentationDetents([.fraction(0.6), .large])
                    .presentationDragIndicator(.hidden)
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.6)))
                    .interactiveDismissDisabled(false)
            }

            VStack {
                Spacer()
                if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                    Text("Veuillez autoriser l'accès à la localisation dans les Réglages")
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }

    private func handleMapSelection(_ selection: MapSelection<MKMapItem>?) {
        guard let feature = selection?.feature else { return }

        Task { @MainActor in
            let request = MKMapItemRequest(feature: feature)
            do {
                // Small delay to ensure MapKit resources are loaded
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

                let mapItem = try await request.mapItem

                // Ensure we're still on main thread when updating UI state
                self.selectedPOI = mapItem
            } catch {
                print("Error loading POI details: \(error.localizedDescription)")
                // Reset selection on error
                self.selection = nil
                self.selectedPOI = nil
            }
        }
    }
}

#Preview {
    MapView()
}
