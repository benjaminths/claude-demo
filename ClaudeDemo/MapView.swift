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
    @StateObject private var announcementManager = POIAnnouncementManager()
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
    @Namespace private var mapScope

    var body: some View {
        ZStack {
            Map(position: $position, selection: $selection, scope: mapScope) {
                UserAnnotation()
            }
            .mapFeatureSelectionAccessory(.callout)
            .overlay(alignment: .topTrailing) {
                VStack(spacing: 12) {
                    Button(action: toggleAnnouncements) {
                        Image(systemName: announcementManager.isAnnouncing ? "speaker.wave.3.fill" : "speaker.slash.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(announcementManager.isAnnouncing ? Color.blue : Color.gray)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }

                    MapUserLocationButton(scope: mapScope)
                        .buttonBorderShape(.circle)
                }
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

                    // Start announcements when location is first available
                    announcementManager.startAnnouncements(location: location)
                }

                // Update announcement location when user moves
                if let location = newLocation, announcementManager.isAnnouncing {
                    announcementManager.currentLocation = location
                }
            }
            .sheet(isPresented: $showingPOIDetails) {
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
            } catch {
                // Silently handle errors
            }
        }
    }

    private func toggleAnnouncements() {
        if announcementManager.isAnnouncing {
            announcementManager.stopAnnouncements()
        } else if let location = locationManager.location {
            announcementManager.startAnnouncements(location: location)
        }
    }
}

#Preview {
    MapView()
}
