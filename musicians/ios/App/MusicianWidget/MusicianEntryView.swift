import WidgetKit
import SwiftUI

/// `.systemSmall` face: full-bleed portrait, a bottom scrim for legibility,
/// the musician's name (sans) and one-line fact (serif — mirroring the app's
/// Newsreader editorial voice). Dark Jazzlore base (#0a0a0a). Tapping opens
/// that musician in the app via the custom URL scheme.
///
/// Typography note: the app self-hosts Geist (sans) + Newsreader (serif) as
/// woff2, which iOS can't bundle. These are system stand-ins chosen to match
/// the app's character (clean sans name, editorial serif fact); dropping in
/// the real OFL .ttf faces is a clean later refinement.
struct MusicianEntryView: View {
    var entry: MusicianEntry

    private let base = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255) // #0a0a0a
    private let accent = Color(red: 244 / 255, green: 162 / 255, blue: 51 / 255) // #f4a233

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(entry.musician.assetName)
                .resizable()
                .scaledToFill()

            // Legibility scrim — transparent at top, near-black at the bottom.
            LinearGradient(
                colors: [.black.opacity(0.0), .black.opacity(0.55), .black.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

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
            .padding(12)
        }
        .widgetURL(deepLinkURL)
        .widgetBackground(base)
    }

    private var deepLinkURL: URL? {
        URL(string: "jazzlore-musicians://musician/\(entry.musician.id)")
    }
}

private extension View {
    /// `containerBackground` is required when building against the iOS 17 SDK;
    /// fall back to a plain background on iOS 16.
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(color, for: .widget)
        } else {
            background(color)
        }
    }
}
