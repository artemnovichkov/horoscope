//
//  Created by Artem Novichkov on 27.07.2025.
//

import FoundationModels

final class HoroscopeService: Sendable {

    private var session = LanguageModelSession(tools: [UserInfoTool(), GithubInfoTool()]) {
                        """
                        Your job is to create a horoscope for developers.
                        Always use the fetchUserInfo tool to get zodiac sign and gender. 
                        Always use the fetchGithubInfo tool to get user info and repos from Github.
                        The horoscope must be funny and witty.
                        """
    }

    func prewarm() {
        session.prewarm()
    }

    func horoscope(username: String) async throws -> Horoscope {
        try await session.respond(generating: Horoscope.self,
                                  includeSchemaInPrompt: false) {
            prompt(username: username)
        }.content
    }

    func horoscopeStream(username: String) -> LanguageModelSession.ResponseStream<Horoscope> {
        session.streamResponse(generating: Horoscope.self,
                               includeSchemaInPrompt: false) {
            prompt(username: username)
        }
    }

    // MARK: - Private

    @PromptBuilder
    private func prompt(username: String) -> Prompt {
        "Generate a today horoscope based on zodiac sign, gender, and Github information for username: \(username)."
    }
}
