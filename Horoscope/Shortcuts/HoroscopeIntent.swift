//
//  Created by Artem Novichkov on 27.07.2025.
//

import AppIntents
import SwiftUI

/// An App Intent that generates a developer horoscope based on a GitHub username.
///
/// This intent is used to trigger horoscope generation through system integrations
/// such as Siri, Shortcuts, or Spotlight. It calls `HoroscopeService` to fetch
/// the result and returns a `HoroscopeView` to display it.
///
/// - Parameters:
///   - username: The GitHub username used to generate a personalized horoscope.
/// - Returns: A rendered `HoroscopeView` inside a system snippet UI.
final class HoroscopeIntent: AppIntent {
    static var parameterSummary: some ParameterSummary {
        Summary("Generate a horoscope for \(\.$username)")
    }

    static var title: LocalizedStringResource = "Horoscope"

    static var description = IntentDescription("Generates a horoscope")

    @Parameter(title: "Github username")
    var username: String

    @Dependency
    private var horoscopeService: HoroscopeService

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let horoscope = try await horoscopeService.horoscope(username: username)
        return .result(view: HoroscopeView(horoscope: horoscope))
    }
}
