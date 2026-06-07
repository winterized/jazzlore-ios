import WidgetKit

struct MusicianEntry: TimelineEntry {
    let date: Date
    let musician: WidgetMusician
}

/// Pre-computes one midnight-stamped entry per day for the next N days, so the
/// widget face flips at each local midnight with NO code running at midnight
/// (WidgetKit just advances the timeline). `.atEnd` regenerates when the
/// window runs out. No network, no persistent state — see `MusicianRotation`.
struct Provider: TimelineProvider {
    static let scheduleDepthDays = 30

    func placeholder(in context: Context) -> MusicianEntry {
        entry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (MusicianEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MusicianEntry>) -> Void) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let entries: [MusicianEntry] = (0..<Self.scheduleDepthDays).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today).map(entry(for:))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(for date: Date) -> MusicianEntry {
        let day = Calendar.current.startOfDay(for: date)
        let musician = MusicianRotation.musician(for: day, in: WidgetContent.pool)
            ?? WidgetContent.placeholder
        return MusicianEntry(date: day, musician: musician)
    }
}
