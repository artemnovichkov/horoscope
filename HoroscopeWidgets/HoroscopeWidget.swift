//
//  Created by Artem Novichkov on 30.07.2025.
//

import WidgetKit
import SwiftUI

/// The main widget entry point for the Horoscope widget extension.
///
/// This struct conforms to the `Widget` protocol and defines a static widget configuration using
/// `HoroscopeIntentTimelineProvider` to provide entries and `WidgetView` to display the widget UI.
///
/// The widget is identified by a unique `kind` string and provides localized display name and description
/// for use in the widget gallery.
struct HoroscopeWidget: Widget {
    let kind: String = "HoroscopeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HoroscopeIntentTimelineProvider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName(.horoscope)
        .description(.generateAHoroscope)
    }
}

/// The main SwiftUI view displayed in the widget.
/// Renders a wand icon with adaptive foreground and background colors depending on platform.
struct WidgetView: View {

    let entry: HoroscopeEntry

    var body: some View {
        Image(systemName: "wand.and.sparkles")
            .resizable()
            .symbolRenderingMode(.hierarchical)
            #if os(iOS) || os(visionOS)
            .foregroundStyle(Color(.label))
            #else
            .foregroundStyle(Color(.labelColor))
            #endif
            .aspectRatio(contentMode: .fit)
            .padding()
            .containerBackground(for: .widget) {
            #if os(iOS) || os(visionOS)
                Color(.tertiarySystemBackground)
            #else
                Color(.tertiarySystemFill)
            #endif
            }
            .widgetURL(.horoscopeURL)
    }
}

/// A static timeline provider returning a single entry with the current date.
/// This implementation disables periodic updates (`.never` policy).
struct HoroscopeIntentTimelineProvider: TimelineProvider {

    typealias Entry = HoroscopeEntry

    func placeholder(in context: Context) -> HoroscopeEntry {
        .init(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (HoroscopeEntry) -> Void) {
        completion(.init(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HoroscopeEntry>) -> Void) {
        completion(.init(entries: [.init(date: .now)], policy: .never))
    }
}

/// A basic timeline entry containing only a date.
/// Used to render the widget at a single point in time.
struct HoroscopeEntry: TimelineEntry {
    let date: Date
}

#Preview(as: .systemMedium) {
    HoroscopeWidget()
} timeline: {
    HoroscopeEntry(date: .now)
}
