//
//  Created by Artem Novichkov on 26.07.2025.
//

import SwiftUI
import AppIntents
import TipKit

@main
struct HoroscopeApp: App {

    init() {
        let horoscopeService = HoroscopeService()
        AppDependencyManager.shared.add(dependency: horoscopeService)
        HoroscopeShortcutProvider.updateAppShortcutParameters()
        do {
            #if DEBUG
            Tips.showAllTipsForTesting()
            #endif
            try Tips.configure()
        } catch {
            print("Error initializing TipKit \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .colorScheme(.dark)
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
