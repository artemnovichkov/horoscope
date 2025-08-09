//
//  Created by Artem Novichkov on 26.07.2025.
//

import SwiftUI
import AppIntents
import TipKit

@main
struct HoroscopeApp: App {
#if !os(macOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let horoscopeService = HoroscopeService()
        AppDependencyManager.shared.add(dependency: horoscopeService)
        HoroscopeShortcutProvider.updateAppShortcutParameters()
        setupTips()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .colorScheme(.dark)
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            if newScenePhase == .background {
                setupShortcutsItems()
            }
        }
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }

    // MARK: - Private

    private func setupShortcutsItems() {
#if !os(macOS)
        let horoscopeItem = UIApplicationShortcutItem(
            type: ShortcutType.generateHoroscope.rawValue,
            localizedTitle: "Get your horoscope",
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: "wand.and.sparkles"),
            userInfo: nil
        )

        UIApplication.shared.shortcutItems = [horoscopeItem]
#endif
    }

    private func setupTips() {
        do {
#if DEBUG
            Tips.showAllTipsForTesting()
#endif
            try Tips.configure()
        } catch {
            print("Error initializing TipKit \(error.localizedDescription)")
        }
    }
}

enum ShortcutType: String {
    case generateHoroscope = "generateHoroscope"
}
