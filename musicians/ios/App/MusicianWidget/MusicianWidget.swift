import WidgetKit
import SwiftUI

// The widget definition. The entry/provider live in Provider.swift, the model
// + rotation in Model.swift, and the view in MusicianEntryView.swift.

struct MusicianWidget: Widget {
    let kind = "MusicianWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MusicianEntryView(entry: entry)
        }
        .configurationDisplayName("Jazz Musicians")
        .description("Discover a new jazz musician every day.")
        .supportedFamilies([.systemSmall])
    }
}
