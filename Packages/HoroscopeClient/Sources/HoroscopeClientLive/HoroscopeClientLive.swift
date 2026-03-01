import HoroscopeClient

@MainActor
public extension HoroscopeClient {
    static let live: HoroscopeClient = {
        let service = HoroscopeService()
        return HoroscopeClient(
            generate: { username in
                service.horoscopeStream(username: username)
            },
            horoscope: { username in
                try await service.horoscope(username: username)
            },
            prewarm: { username in
                service.prewarm(username: username)
            },
            session: {
                service.session
            }
        )
    }()
}
