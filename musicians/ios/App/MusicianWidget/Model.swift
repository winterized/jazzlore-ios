import Foundation

/// One musician in the widget's bundled rotation pool. Matches the JSON shape
/// emitted by the web monorepo's `scripts/generate-widget-content.mjs`.
struct WidgetMusician: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let fact: String
    let deepLinkPath: String

    /// Asset-catalog name for this musician's portrait. MUST stay identical to
    /// the generator's `assetName` rule (`id.replace(/[^A-Za-z0-9]/g, '_')`):
    /// `wikidata:Q93341` → `wikidata_Q93341`. Uses an ASCII-only test on
    /// purpose — `Character.isLetter`/`isNumber` are Unicode-aware and would
    /// diverge from the JS `[A-Za-z0-9]` for non-ASCII ids. Pinned by a test.
    var assetName: String {
        String(id.map { c in
            let ascii = c.asciiValue
            let isAlnum = ascii.map {
                ($0 >= 48 && $0 <= 57) || ($0 >= 65 && $0 <= 90) || ($0 >= 97 && $0 <= 122)
            } ?? false
            return isAlnum ? c : "_"
        })
    }
}

/// Deterministic "musician of the day" selection — pure, stateless.
///
/// NOTE (issue flagged to Aurélien): the widget design uses sequential
/// `daysSinceEpoch % poolSize`, NOT Swift's `Int.hashValue % poolSize`.
/// Swift's `Hashable` uses a per-process random seed, so `.hashValue` is NOT
/// stable across launches — it would make the daily pick non-deterministic
/// and could repeat a musician within a single rotation cycle. Sequential
/// modulo is deterministic, sweeps the whole pool before repeating, and
/// matches the build-time interleave (greats spread evenly).
enum MusicianRotation {
    /// Whole days from the Unix epoch to the start of `date`'s day in `calendar`.
    static func dayNumber(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let epoch = Date(timeIntervalSince1970: 0)
        return calendar.dateComponents([.day], from: epoch, to: start).day ?? 0
    }

    /// Pool index for `date`. Safe (non-negative) modulo; 0 for an empty pool.
    static func index(for date: Date, count: Int, calendar: Calendar = .current) -> Int {
        guard count > 0 else { return 0 }
        let d = dayNumber(for: date, calendar: calendar)
        return ((d % count) + count) % count
    }

    static func musician(
        for date: Date,
        in pool: [WidgetMusician],
        calendar: Calendar = .current
    ) -> WidgetMusician? {
        guard !pool.isEmpty else { return nil }
        return pool[index(for: date, count: pool.count, calendar: calendar)]
    }
}

/// The bundled pool, loaded once from `musicians.json` in the widget bundle.
/// A hard-coded `placeholder` keeps the widget rendering even if the bundle
/// read ever fails (it shouldn't — the JSON ships in the .appex).
enum WidgetContent {
    static let placeholder = WidgetMusician(
        id: "wikidata:Q93341",
        name: "Miles Davis",
        fact: "Reinvented jazz five times and never looked back.",
        deepLinkPath: "/musicians/wikidata%3AQ93341"
    )

    static let pool: [WidgetMusician] = {
        guard
            let url = Bundle.main.url(forResource: "musicians", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([WidgetMusician].self, from: data),
            !decoded.isEmpty
        else {
            return [placeholder]
        }
        return decoded
    }()

    /// Stable, recognizable card for the widget gallery + loading state — the
    /// curated flagship (Miles Davis), independent of today's rotation, so the
    /// gallery always shows a polished representative.
    static let preview: WidgetMusician = pool.first { $0.id == placeholder.id } ?? placeholder
}
