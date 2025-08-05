//
//  Created by Artem Novichkov on 27.07.2025.
//

import FoundationModels


/// A service responsible for generating developer horoscopes using Foundation Models.
///
/// This service integrates with tools for fetching user information and GitHub data
/// to generate personalized, witty horoscopes for developers. It supports both full
/// result generation and streaming updates.
///
/// Use `horoscope(username:)` for complete results or `horoscopeStream(username:)` for streamed output.
/// Call `prewarm(username:)` in advance to reduce latency.
final class HoroscopeService {

    private(set) lazy var session = LanguageModelSession(tools: [UserInfoTool(), GithubInfoTool()]) {
        """
        Your job is to create a horoscope for developers.
        Always use the fetchUserInfo tool to get zodiac sign and gender. 
        Always use the fetchGithubInfo tool to get user info and repos from Github.
        The horoscope must be funny and witty.
        """
    }

    /// Prewarms the language model session with an optional GitHub username.
    /// - Parameter username: An optional GitHub username used to prefill the prompt.
    func prewarm(username: String?) {
        var promptPrefix: Prompt?
        if let username {
            promptPrefix = prompt(username: username)
        }
        session.prewarm(promptPrefix: promptPrefix)
    }

    /// Generates a horoscope for a given GitHub username.
    /// - Parameter username: The GitHub username to generate the horoscope for.
    /// - Returns: A `Horoscope` instance containing the generated horoscope.
    /// - Throws: An error if the generation fails.
    func horoscope(username: String) async throws -> Horoscope {
        try await session.respond(generating: Horoscope.self,
                                  includeSchemaInPrompt: false) {
            prompt(username: username)
        }.content
    }

    /// Streams a horoscope generation result for a given GitHub username.
    /// - Parameter username: The GitHub username to generate the horoscope for.
    /// - Returns: A `ResponseStream` emitting `Horoscope` updates from the language model.
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
