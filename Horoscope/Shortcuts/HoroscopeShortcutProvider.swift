//
//  Created by Artem Novichkov on 27.07.2025.
//

import AppIntents

final class HoroscopeShortcutProvider: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: HoroscopeIntent(),
            phrases: [
                "Get my horoscope in \(.applicationName)",
                "Show my horoscope \(.applicationName)",
                "Horoscope \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource("Horoscope"),
            systemImageName: "wand.and.sparkles"
        )
    }
}
