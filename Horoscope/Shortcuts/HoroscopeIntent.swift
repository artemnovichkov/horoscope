//
//  Created by Artem Novichkov on 27.07.2025.
//

import AppIntents
import SwiftUI

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
