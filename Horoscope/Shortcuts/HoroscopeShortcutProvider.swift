//
//  Created by Artem Novichkov on 27.07.2025.
//

import AppIntents

/// Provides predefined app shortcuts for generating developer horoscopes via App Intents.
///
/// This class defines phrases and metadata for system-level integrations, such as Siri and Spotlight.
/// It links to `HoroscopeIntent` to enable users to trigger horoscope generation with voice or search.
///
/// Use this provider to register shortcut phrases like “Get my horoscope” for enhanced app interaction.
final class HoroscopeShortcutProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: HoroscopeIntent(),
            phrases: [
                "Get my horoscope in \(.applicationName)",
                "Show my horoscope \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource("Horoscope"),
            systemImageName: "wand.and.sparkles"
        )
    }
}
