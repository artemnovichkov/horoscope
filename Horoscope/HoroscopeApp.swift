//
//  Created by Artem Novichkov on 26.07.2025.
//

import SwiftUI
import AppIntents
import TipKit

@main
struct HoroscopeApp: App {

    init() {
        AppDependencyManager.shared.add(dependency: HoroscopeService())
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
    }
}
