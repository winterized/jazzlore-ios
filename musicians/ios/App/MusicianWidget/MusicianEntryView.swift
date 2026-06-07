import WidgetKit
import SwiftUI

/// `.systemSmall` face: the portrait fills the ENTIRE widget (edge-to-edge),
/// with a bottom legibility scrim, the musician's name (sans) and one-line
/// fact (serif — mirroring the app's Newsreader editorial voice). Dark
/// Jazzlore base (#0a0a0a) shows only if a portrait is ever missing. Tapping
/// opens that musician in the app via the custom URL scheme.
///
/// Full-bleed is achieved by putting the portrait in `containerBackground`,
/// which WidgetKit extends to the widget's edges (the foreground caption still
/// respects the system content margins). On iOS 16 (no containerBackground /
/// no content margins) the portrait is a manually-padded ZStack background.
///
/// Typography note: the app's Geist (sans) + Newsreader (serif) ship as woff2,
/// which iOS can't bundle, so these are system stand-ins chosen to match the
/// app's character; the real OFL .ttf faces are a clean later refinement.
struct MusicianEntryView: View {
    var entry: MusicianEntry

    private let base = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255) // #0a0a0a
    private let accent = Color(red: 244 / 255, green: 162 / 255, blue: 51 / 255) // #f4a233

    /// Edge-to-edge portrait + bottom scrim.
    private var portrait: some View {
        ZStack {
            base
            Image(entry.musician.assetName)
                .resizable()
                .scaledToFill()
            LinearGradient(
                colors: [.black.opacity(0.0), .black.opacity(0.55), .black.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    /// Name + fact, pinned bottom-leading.
    private var caption: some View {
        VStack(alignment: .leading, spacing: 3) {
            Rectangle()
                .fill(accent)
                .frame(width: 18, height: 2)
                .padding(.bottom, 1)
            Text(entry.musician.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(entry.musician.fact)
                .font(.system(size: 11.5, design: .serif))
                .italic()
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(2)
        }
        .shadow(color: .black.opacity(0.6), radius: 3, y: 1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            caption
                .containerBackground(for: .widget) { portrait }
                .widgetURL(deepLinkURL)
        } else {
            ZStack(alignment: .bottomLeading) {
                portrait
                caption.padding(12)
            }
            .widgetURL(deepLinkURL)
        }
    }

    private var deepLinkURL: URL? {
        URL(string: "jazzlore-musicians://musician/\(entry.musician.id)")
    }
}
