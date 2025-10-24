//
//  ClaudeDemoLiveActivityLiveActivity.swift
//  ClaudeDemoLiveActivity
//
//  Created by Benjamin on 23/10/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

// POI Activity Attributes (shared with main app)
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

// App Intents for Live Activity buttons
struct DirectionsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Directions"

    func perform() async throws -> some IntentResult {
        // This would open Maps app with directions
        return .result()
    }
}

struct CallIntent: AppIntent {
    static var title: LocalizedStringResource = "Call"

    func perform() async throws -> some IntentResult {
        // This would initiate a phone call
        return .result()
    }
}

struct ClaudeDemoLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: POIActivityAttributes.self) { context in
            // Lock screen/banner UI
            POILockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(Color.blue.opacity(0.2))
                .activitySystemActionForegroundColor(Color.blue)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: categoryIcon(for: context.attributes.poiCategory))
                            .font(.title2)
                            .foregroundStyle(.blue)
                        Text(context.attributes.poiCategory)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatDistance(context.state.distance))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        Text("distance")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        Text(context.attributes.poiName)
                            .font(.headline)
                            .lineLimit(2)

                        HStack(spacing: 16) {
                            Button(intent: DirectionsIntent()) {
                                Label("Itinéraire", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                                    .font(.caption)
                            }

                            if context.attributes.phoneNumber != nil {
                                Button(intent: CallIntent()) {
                                    Label("Appeler", systemImage: "phone.circle.fill")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                Image(systemName: categoryIcon(for: context.attributes.poiCategory))
                    .foregroundStyle(.blue)
            } compactTrailing: {
                Text(formatDistance(context.state.distance))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            } minimal: {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.blue)
            }
            .keylineTint(Color.blue)
        }
    }

    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }

    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "restaurant": return "fork.knife"
        case "café": return "cup.and.saucer.fill"
        case "hôtel": return "bed.double.fill"
        case "magasin": return "cart.fill"
        case "musée": return "building.columns.fill"
        case "parc": return "tree.fill"
        case "pharmacie": return "cross.fill"
        case "hôpital": return "cross.case.fill"
        case "banque": return "banknote.fill"
        default: return "mappin.circle.fill"
        }
    }
}

struct POILockScreenView: View {
    let attributes: POIActivityAttributes
    let state: POIActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: categoryIcon(for: attributes.poiCategory))
                .font(.title)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.blue.opacity(0.1)))

            VStack(alignment: .leading, spacing: 4) {
                Text(attributes.poiName)
                    .font(.headline)
                    .lineLimit(1)

                Text(attributes.poiCategory)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: "figure.walk")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatDistance(state.distance))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
        }
        .padding(12)
    }

    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }

    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "restaurant": return "fork.knife"
        case "café": return "cup.and.saucer.fill"
        case "hôtel": return "bed.double.fill"
        case "magasin": return "cart.fill"
        case "musée": return "building.columns.fill"
        case "parc": return "tree.fill"
        case "pharmacie": return "cross.fill"
        case "hôpital": return "cross.case.fill"
        case "banque": return "banknote.fill"
        default: return "mappin.circle.fill"
        }
    }
}

extension POIActivityAttributes {
    fileprivate static var preview: POIActivityAttributes {
        POIActivityAttributes(
            poiName: "Le Petit Bistro",
            poiCategory: "Restaurant",
            poiLatitude: 48.8566,
            poiLongitude: 2.3522,
            phoneNumber: "+33 1 23 45 67 89"
        )
    }
}

extension POIActivityAttributes.ContentState {
    fileprivate static var nearby: POIActivityAttributes.ContentState {
        POIActivityAttributes.ContentState(
            distance: 150,
            userLatitude: 48.8570,
            userLongitude: 2.3525
        )
     }

     fileprivate static var far: POIActivityAttributes.ContentState {
         POIActivityAttributes.ContentState(
            distance: 1250,
            userLatitude: 48.8700,
            userLongitude: 2.3650
        )
     }
}

#Preview("Notification", as: .content, using: POIActivityAttributes.preview) {
   ClaudeDemoLiveActivityLiveActivity()
} contentStates: {
    POIActivityAttributes.ContentState.nearby
    POIActivityAttributes.ContentState.far
}
