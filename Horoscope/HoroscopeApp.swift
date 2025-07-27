//
//  Created by Artem Novichkov on 26.07.2025.
//

import SwiftUI
import AppIntents

@main
struct HoroscopeApp: App {

    init() {
        AppDependencyManager.shared.add(dependency: HoroscopeService())
        HoroscopeShortcutProvider.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .colorScheme(.dark)
        }
    }
}
