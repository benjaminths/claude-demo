//
//  POIDetailView.swift
//  ClaudeDemo
//
//  Created by Benjamin on 23/10/2025.
//

import SwiftUI
import MapKit

struct POIDetailView: View {
    let poi: MKMapItem
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding(.trailing)
                }
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(poi.name ?? "Lieu inconnu")
                                .font(.title2)
                                .fontWeight(.bold)

                            if let category = poi.pointOfInterestCategory, let locality = poi.placemark.locality {
                                Text("\(categoryName(for: category)) · \(locality)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else if let category = poi.pointOfInterestCategory {
                                Text(categoryName(for: category))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if let coordinate = poi.placemark.location?.coordinate {
                                ActionButton(icon: "figure.walk", label: calculateDistance(to: coordinate), color: .blue)
                            }

                            if poi.phoneNumber != nil {
                                ActionButton(icon: "phone.fill", label: "Appeler", color: .gray)
                            }

                            if poi.url != nil {
                                ActionButton(icon: "safari.fill", label: "Site web", color: .gray)
                            }

                            ActionButton(icon: "square.and.arrow.up", label: "Partager", color: .gray)

                            ActionButton(icon: "ellipsis", label: "Plus", color: .gray)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                    .contentMargins(.horizontal, 0, for: .scrollContent)

                    Divider()

                    HStack(spacing: 0) {
                        InfoCell(title: "DISTANCE", value: calculateDistance(to: poi.placemark.coordinate))

                        Divider()
                            .frame(height: 40)

                        if let category = poi.pointOfInterestCategory {
                            InfoCell(title: "CATÉGORIE", value: categoryName(for: category))
                        }
                    }
                    .frame(height: 70)

                    Divider()

                    if let address = formatAddress(poi.placemark) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Adresse", systemImage: "mappin.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()
                    }

                    if let phone = poi.phoneNumber {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Téléphone", systemImage: "phone.fill")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(phone)
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()
                    }

                    if let url = poi.url {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Site web", systemImage: "safari.fill")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(url.absoluteString)
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Coordonnées", systemImage: "location.fill")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(String(format: "%.4f, %.4f",
                                  poi.placemark.coordinate.latitude,
                                  poi.placemark.coordinate.longitude))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }

    private func calculateDistance(to coordinate: CLLocationCoordinate2D) -> String {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let userLocation = CLLocation(latitude: 48.8566, longitude: 2.3522)
        let distance = userLocation.distance(from: location)

        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }

    private func categoryName(for category: MKPointOfInterestCategory) -> String {
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
        default: return category.rawValue
        }
    }

    private func categoryIcon(for category: MKPointOfInterestCategory) -> String {
        switch category {
        case .restaurant: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        case .hotel: return "bed.double.fill"
        case .store: return "cart.fill"
        case .museum: return "building.columns.fill"
        case .park: return "tree.fill"
        case .theater: return "theatermasks.fill"
        case .library: return "books.vertical.fill"
        case .school: return "graduationcap.fill"
        case .hospital: return "cross.case.fill"
        case .pharmacy: return "cross.fill"
        case .bakery: return "birthday.cake.fill"
        case .brewery: return "wineglass.fill"
        case .winery: return "wineglass.fill"
        case .gasStation: return "fuelpump.fill"
        case .parking: return "parkingsign.circle.fill"
        case .postOffice: return "envelope.fill"
        case .publicTransport: return "bus.fill"
        case .airport: return "airplane"
        case .bank: return "banknote.fill"
        case .atm: return "creditcard.fill"
        case .beach: return "beach.umbrella.fill"
        case .campground: return "tent.fill"
        case .laundry: return "washer.fill"
        case .movieTheater: return "film.fill"
        case .nightlife: return "music.note"
        case .stadium: return "sportscourt.fill"
        case .zoo: return "pawprint.fill"
        default: return "mappin.circle.fill"
        }
    }

    private func formatAddress(_ placemark: MKPlacemark) -> String? {
        var components: [String] = []

        if let street = placemark.thoroughfare {
            components.append(street)
        }
        if let city = placemark.locality {
            components.append(city)
        }
        if let postalCode = placemark.postalCode {
            components.append(postalCode)
        }

        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color == .blue ? Color.blue : Color(uiColor: .systemGray5))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color == .blue ? .white : .primary)
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .frame(width: 70)
    }
}

struct InfoCell: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let coordinate = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = "Tour Eiffel"
    mapItem.phoneNumber = "+33 1 23 45 67 89"

    return POIDetailView(poi: mapItem)
        .presentationDetents([.height(400), .large])
}
