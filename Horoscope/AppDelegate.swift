//
//  Created by Artem Novichkov on 02.08.2025.
//

#if os(iOS)
import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        UIApplication.shared.open(.horoscopeURL, options: [:], completionHandler: nil)
        completionHandler(true)
    }
}
#endif
