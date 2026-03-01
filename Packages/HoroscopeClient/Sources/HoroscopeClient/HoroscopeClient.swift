import FoundationModels

@Generable
public struct Horoscope: Equatable {
    @Guide(description: "Zodiac sign.")
    public let sign: String

    @Guide(description: "Today's horoscope message for the developer. Based on the zodiac sign and user's GitHub information.")
    public let message: String
}

public struct HoroscopeClient: Sendable {
    public var generate: @Sendable (String) -> LanguageModelSession.ResponseStream<Horoscope>
    public var horoscope: @Sendable (String) async throws -> Horoscope
    public var prewarm: @Sendable (String?) -> Void

    public init(
        generate: @escaping @Sendable (String) -> LanguageModelSession.ResponseStream<Horoscope>,
        horoscope: @escaping @Sendable (String) async throws -> Horoscope,
        prewarm: @escaping @Sendable (String?) -> Void
    ) {
        self.generate = generate
        self.horoscope = horoscope
        self.prewarm = prewarm
    }
}
