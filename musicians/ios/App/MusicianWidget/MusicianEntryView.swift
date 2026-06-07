import WidgetKit
import SwiftUI

// Phase 0: "Jazz" centred on the Jazzlore near-black (#0a0a0a). Real portrait
// + name + fact layout lands in Phase 3.
struct MusicianEntryView: View {
    var entry: MusicianEntry

    private let background = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)

    var body: some View {
        Text("Jazz")
            .font(.system(.title, design: .serif).weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .widgetBackground(background)
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
