import WidgetKit
import SwiftUI

// Phase 0 scaffold: a static "hello world" widget. The entry, provider, and
// view get fleshed out in later phases (Model/Provider split in Phase 2,
// real layout in Phase 3). For now this is just enough to confirm the
// extension builds, signs, and appears in the widget gallery.

struct MusicianEntry: TimelineEntry {
    let date: Date
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MusicianEntry {
        MusicianEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (MusicianEntry) -> Void) {
        completion(MusicianEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MusicianEntry>) -> Void) {
        completion(Timeline(entries: [MusicianEntry(date: Date())], policy: .never))
    }
}

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
