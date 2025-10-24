//
//  POIActivityAttributes.swift
//  ClaudeDemo
//
//  Created by Benjamin on 24/10/2025.
//

import Foundation
import ActivityKit

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
