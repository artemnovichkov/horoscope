//
//  HoroscopeWidgets.swift
//  HoroscopeWidgets
//
//  Created by Artem Novichkov on 30.07.2025.
//

import WidgetKit
import SwiftUI

@main
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

struct WidgetView: View {

    let entry: HoroscopeEntry

    var body: some View {
        Image(systemName: "wand.and.sparkles")
            .resizable()
            .symbolRenderingMode(.hierarchical)
            #if os(iOS)
            .foregroundStyle(Color(.label))
            #else
            .foregroundStyle(Color(.labelColor))
            #endif
            .aspectRatio(contentMode: .fit)
            .padding()
            .containerBackground(for: .widget) {
            #if os(iOS)
                Color(.tertiarySystemBackground)
            #else
                Color(.tertiarySystemFill)
            #endif
            }
            .widgetURL(URL(string: "horoscope://"))
    }
}

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

struct HoroscopeEntry: TimelineEntry {
    let date: Date
}

#Preview(as: .systemLarge) {
    HoroscopeWidget()
} timeline: {
    HoroscopeEntry(date: .now)
}
