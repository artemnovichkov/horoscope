import FoundationModels
import GithubClientLive
import HoroscopeClient

public extension HoroscopeClient {
    static let live: HoroscopeClient = {
        let session = LanguageModelSession(tools: [UserInfoTool(), GithubInfoTool()]) {
            """
            Your job is to create a horoscope for developers.

            For each request from the user:
            - get the zodiac sign and the gender using the fetchUserInfo tool.
            - get Github data using the fetchGithubInfo tool.
            """
        }

        @PromptBuilder @Sendable
        func prompt(username: String) -> Prompt {
            "Generate a funny, witty today horoscope combining zodiac sign, gender and coding activity for username: \(username)."
        }

        return HoroscopeClient(
            generate: { username in
                session.streamResponse(generating: Horoscope.self) {
                    prompt(username: username)
                }
            },
            horoscope: { username in
                try await session.respond(generating: Horoscope.self) {
                    prompt(username: username)
                }.content
            },
            prewarm: { username in
                var promptPrefix: Prompt?
                if let username {
                    promptPrefix = prompt(username: username)
                }
                session.prewarm(promptPrefix: promptPrefix)
            },
            session: {
                session
            }
        )
    }()
}
