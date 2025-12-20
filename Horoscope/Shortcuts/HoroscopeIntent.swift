//
//  Created by Artem Novichkov on 27.07.2025.
//

import AppIntents
import SwiftUI
import FoundationModels

/// An App Intent that generates a developer horoscope based on a GitHub username.
///
/// This intent is used to trigger horoscope generation through system integrations
/// such as Siri, Shortcuts, or Spotlight. It calls `HoroscopeService` to fetch
/// the result and returns a `HoroscopeView` to display it.
///
/// The username is retrieved from UserDefaults using the same key as the main app.
///
/// - Returns: A rendered `HoroscopeView` inside a system snippet UI.
struct HoroscopeIntent: AppIntent {
    static var parameterSummary: some ParameterSummary {
        Summary("Generate a horoscope")
    }

    static var title: LocalizedStringResource = "Horoscope"
    static var description = IntentDescription("Generates a horoscope")

    @Dependency
    private var horoscopeService: HoroscopeService

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        if username.isEmpty {
            throw HoroscopeIntentError.missingUsername
        }
        let horoscope = try await horoscopeService.horoscope(username: username)
        return .result(view: HoroscopeView(horoscope: horoscope.asPartiallyGenerated()))
    }
}

private enum HoroscopeIntentError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case missingUsername

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .missingUsername:
            "Please open the app and add your GitHub username first"
        }
    }
}
