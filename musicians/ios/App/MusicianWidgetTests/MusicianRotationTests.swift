import XCTest

// Model.swift is compiled into this test target (it's a pure-logic file with
// no WidgetKit dependency), so the types are visible without an import.
final class MusicianRotationTests: XCTestCase {
    /// Fixed UTC Gregorian calendar so the tests are timezone/DST-independent.
    private let cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    private func pool(_ n: Int) -> [WidgetMusician] {
        (0..<n).map {
            WidgetMusician(id: "wikidata:Q\($0)", name: "M\($0)", fact: "f", deepLinkPath: "/musicians/x")
        }
    }

    private func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d, hour: 12))!
    }

    func testDeterministicForSameDate() {
        let p = pool(39)
        let d = day(2026, 6, 7)
        let a = MusicianRotation.musician(for: d, in: p, calendar: cal)
        XCTAssertEqual(a, MusicianRotation.musician(for: d, in: p, calendar: cal))
        // Stable for any time-of-day within the same calendar day.
        let evening = cal.date(byAdding: .hour, value: 9, to: d)!
        XCTAssertEqual(MusicianRotation.musician(for: evening, in: p, calendar: cal), a)
    }

    func testAdvancesByOnePerDay() {
        let p = pool(39)
        let i0 = MusicianRotation.index(for: day(2026, 6, 7), count: p.count, calendar: cal)
        let i1 = MusicianRotation.index(for: day(2026, 6, 8), count: p.count, calendar: cal)
        XCTAssertEqual(i1, (i0 + 1) % p.count)
    }

    func testCoversEveryMusicianOverOneCycle() {
        let p = pool(39)
        var seen = Set<String>()
        let start = day(2026, 1, 1)
        for offset in 0..<p.count {
            let d = cal.date(byAdding: .day, value: offset, to: start)!
            seen.insert(MusicianRotation.musician(for: d, in: p, calendar: cal)!.id)
        }
        XCTAssertEqual(seen.count, p.count, "every musician should appear exactly once per cycle")
    }

    func testNoRepeatsWithinShorterWindows() {
        let p = pool(39)
        let start = day(2026, 3, 15)
        for windowLen in [2, 7, 14, 30, p.count] {
            var seen = Set<String>()
            for offset in 0..<windowLen {
                let d = cal.date(byAdding: .day, value: offset, to: start)!
                let id = MusicianRotation.musician(for: d, in: p, calendar: cal)!.id
                XCTAssertFalse(seen.contains(id), "repeat within a \(windowLen)-day window")
                seen.insert(id)
            }
        }
    }

    func testWrapsToStartAfterAFullCycle() {
        let p = pool(39)
        let start = day(2026, 1, 1)
        let first = MusicianRotation.musician(for: start, in: p, calendar: cal)!.id
        let afterCycle = cal.date(byAdding: .day, value: p.count, to: start)!
        XCTAssertEqual(MusicianRotation.musician(for: afterCycle, in: p, calendar: cal)!.id, first)
    }

    func testEmptyPoolIsSafe() {
        XCTAssertNil(MusicianRotation.musician(for: day(2026, 6, 7), in: [], calendar: cal))
        XCTAssertEqual(MusicianRotation.index(for: day(2026, 6, 7), count: 0, calendar: cal), 0)
    }

    /// Pins the asset-name contract shared with the generator
    /// (`scripts/generate-widget-content.mjs` `assetName`). A divergence here
    /// silently breaks portrait lookup (not catchable by the build).
    func testAssetNameMatchesGeneratorRule() {
        let cases = [
            ("wikidata:Q93341", "wikidata_Q93341"),
            ("wikidata:Q570001", "wikidata_Q570001"),
            ("musicbrainz:abc-123", "musicbrainz_abc_123"),
        ]
        for (id, expected) in cases {
            let m = WidgetMusician(id: id, name: "x", fact: "y", deepLinkPath: "z")
            XCTAssertEqual(m.assetName, expected)
        }
    }
}
