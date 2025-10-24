//
//  MapView.swift
//  ClaudeDemo
//
//  Created by Benjamin on 23/10/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var liveActivityManager: LiveActivityManager
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var selection: MapSelection<MKMapItem>?
    @State private var selectedPOI: MKMapItem?
    @State private var showingPOIDetails = false
    @State private var hasInitiallyPositioned = false
    @State private var lastLocationUpdateForActivity: CLLocation?
    @Namespace private var mapScope

    init() {
        if #available(iOS 16.1, *) {
            _liveActivityManager = StateObject(wrappedValue: LiveActivityManager())
        } else {
            // Fallback for older iOS versions (though this app targets iOS 18.4+)
            _liveActivityManager = StateObject(wrappedValue: LiveActivityManager())
        }
    }

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

                // Update Live Activity distance if user moved more than 10m
                if let location = newLocation {
                    if let lastLocation = lastLocationUpdateForActivity {
                        let distance = location.distance(from: lastLocation)
                        if distance >= 10 {
                            if #available(iOS 16.1, *) {
                                liveActivityManager.updateDistance(userLocation: location)
                            }
                            lastLocationUpdateForActivity = location
                        }
                    } else {
                        lastLocationUpdateForActivity = location
                    }
                }
            }
            .sheet(isPresented: $showingPOIDetails, onDismiss: {
                // Keep Live Activity running even when sheet is dismissed
                // User can stop it by dismissing the Dynamic Island
            }) {
                if let poi = selectedPOI {
                    POIDetailView(poi: poi)
                        .presentationDetents([.fraction(0.6), .large])
                        .presentationDragIndicator(.hidden)
                        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.6)))
                        .interactiveDismissDisabled(false)
                }
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

        Task {
            let request = MKMapItemRequest(feature: feature)
            do {
                selectedPOI = try await request.mapItem
                showingPOIDetails = true

                // Start Live Activity when POI is selected
                if let poi = selectedPOI, let userLocation = locationManager.location {
                    if #available(iOS 16.1, *) {
                        liveActivityManager.startActivity(poi: poi, userLocation: userLocation)
                    }
                }
            } catch {
                // Silently handle errors
            }
        }
    }
}

#Preview {
    MapView()
}
