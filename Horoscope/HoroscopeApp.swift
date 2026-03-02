//
//  Created by Artem Novichkov on 26.07.2025.
//

import SwiftUI
import AppIntents
import TipKit
import HoroscopeClient
import HoroscopeClientLive
import NotificationsClient
import NotificationsClientLive
import MainFeature

@main
struct HoroscopeApp: App {
#if !os(macOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let horoscopeClient = HoroscopeClient.live
        AppDependencyManager.shared.add(dependency: horoscopeClient)
        HoroscopeShortcutProvider.updateAppShortcutParameters()
        setupTips()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(horoscopeClient: .live, notificationsClient: .live)
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
            let showAllTipsForTesting = ProcessInfo.processInfo.environment["SHOW_ALL_TIPS_FOR_TESTING"]
            if showAllTipsForTesting == "true" {
                Tips.showAllTipsForTesting()
            }
            try Tips.configure()
        } catch {
            print("Error initializing TipKit \(error.localizedDescription)")
        }
    }
}

enum ShortcutType: String {
    case generateHoroscope = "generateHoroscope"
}
