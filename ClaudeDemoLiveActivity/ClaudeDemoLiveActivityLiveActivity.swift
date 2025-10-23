//
//  ClaudeDemoLiveActivityLiveActivity.swift
//  ClaudeDemoLiveActivity
//
//  Created by Benjamin on 23/10/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ClaudeDemoLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ClaudeDemoLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ClaudeDemoLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ClaudeDemoLiveActivityAttributes {
    fileprivate static var preview: ClaudeDemoLiveActivityAttributes {
        ClaudeDemoLiveActivityAttributes(name: "World")
    }
}

extension ClaudeDemoLiveActivityAttributes.ContentState {
    fileprivate static var smiley: ClaudeDemoLiveActivityAttributes.ContentState {
        ClaudeDemoLiveActivityAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ClaudeDemoLiveActivityAttributes.ContentState {
         ClaudeDemoLiveActivityAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ClaudeDemoLiveActivityAttributes.preview) {
   ClaudeDemoLiveActivityLiveActivity()
} contentStates: {
    ClaudeDemoLiveActivityAttributes.ContentState.smiley
    ClaudeDemoLiveActivityAttributes.ContentState.starEyes
}
