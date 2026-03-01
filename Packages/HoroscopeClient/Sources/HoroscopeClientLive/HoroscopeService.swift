import FoundationModels
import GithubClientLive
import HoroscopeClient

@MainActor
final class HoroscopeService {
    private(set) lazy var session = LanguageModelSession(tools: [UserInfoTool(), GithubInfoTool()]) {
        """
        Your job is to create a horoscope for developers.

        For each request from the user:
        - get the zodiac sign and the gender using the fetchUserInfo tool.
        - get Github data using the fetchGithubInfo tool.
        """
    }

    func prewarm(username: String?) {
        var promptPrefix: Prompt?
        if let username {
            promptPrefix = prompt(username: username)
        }
        session.prewarm(promptPrefix: promptPrefix)
    }

    func horoscope(username: String) async throws -> Horoscope {
        try await session.respond(generating: Horoscope.self) {
            prompt(username: username)
        }.content
    }

    func horoscopeStream(username: String) -> LanguageModelSession.ResponseStream<Horoscope> {
        session.streamResponse(generating: Horoscope.self) {
            prompt(username: username)
        }
    }

    @PromptBuilder
    private func prompt(username: String) -> Prompt {
        "Generate a funny, witty today horoscope combining zodiac sign, gender and coding activity for username: \(username)."
    }
}
