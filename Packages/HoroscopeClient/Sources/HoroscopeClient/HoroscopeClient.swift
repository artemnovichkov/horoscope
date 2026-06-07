import FoundationModels

@Generable
public struct Horoscope: Equatable, Sendable {
    @Guide(description: "Zodiac sign.")
    public let sign: String

    @Guide(description: "Today's horoscope message for the developer. Based on the zodiac sign and user's GitHub information.")
    public let message: String
}

public struct HoroscopeClient: Sendable {
    public var generate: @Sendable (String) -> LanguageModelSession.ResponseStream<Horoscope>
    public var horoscope: @Sendable (String) async throws -> Horoscope
    public var prewarm: @Sendable (String?) -> Void
    public var session: @Sendable () -> LanguageModelSession

    public init(
        generate: @escaping @Sendable (String) -> LanguageModelSession.ResponseStream<Horoscope>,
        horoscope: @escaping @Sendable (String) async throws -> Horoscope,
        prewarm: @escaping @Sendable (String?) -> Void,
        session: @escaping @Sendable () -> LanguageModelSession
    ) {
        self.generate = generate
        self.horoscope = horoscope
        self.prewarm = prewarm
        self.session = session
    }
}

#if DEBUG
public extension HoroscopeClient {
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
