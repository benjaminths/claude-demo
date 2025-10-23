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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), // Paris par défaut
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                .edgesIgnoringSafeArea(.all)

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
        .onChange(of: locationManager.location) { oldValue, newValue in
            if let location = newValue {
                region.center = location.coordinate
            }
        }
    }
}

#Preview {
    MapView()
}
