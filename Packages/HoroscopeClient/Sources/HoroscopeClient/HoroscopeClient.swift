import FoundationModels

@Generable
public struct Horoscope: Equatable {
    @Guide(description: "Zodiac sign.")
    public let sign: String

    @Guide(description: "Today's horoscope message for the developer. Based on the zodiac sign and user's GitHub information.")
    public let message: String
}

public struct HoroscopeClient: Sendable {
    public var generate: @MainActor @Sendable (String) -> LanguageModelSession.ResponseStream<Horoscope>
    public var horoscope: @MainActor @Sendable (String) async throws -> Horoscope
    public var prewarm: @MainActor @Sendable (String?) -> Void
    public var session: @MainActor @Sendable () -> LanguageModelSession

    public init(
        generate: @escaping @MainActor @Sendable (String) -> LanguageModelSession.ResponseStream<Horoscope>,
        horoscope: @escaping @MainActor @Sendable (String) async throws -> Horoscope,
        prewarm: @escaping @MainActor @Sendable (String?) -> Void,
        session: @escaping @MainActor @Sendable () -> LanguageModelSession
    ) {
        self.generate = generate
        self.horoscope = horoscope
        self.prewarm = prewarm
        self.session = session
    }
}

#if DEBUG
public extension HoroscopeClient {
    @MainActor
    static let noop: HoroscopeClient = {
        let session = LanguageModelSession { "" }
        return HoroscopeClient(
            generate: { _ in fatalError("Not available in preview") },
            horoscope: { _ in Horoscope(sign: "aries", message: "Your stars align today.") },
            prewarm: { _ in },
            session: { session }
        )
    }()
}
#endif
