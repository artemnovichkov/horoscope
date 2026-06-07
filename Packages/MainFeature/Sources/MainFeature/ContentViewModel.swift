//
//  Created by Artem Novichkov on 27.07.2025.
//

import Foundation
import SwiftUI
import FoundationModels
import HoroscopeClient

@Observable
final class ContentViewModel {
    enum OverlayState: Equatable {
        case normal
        case unavailable(reason: SystemLanguageModel.Availability.UnavailableReason)
        case loading
        case error(String)
    }
    private(set) var overlayState: OverlayState = .normal
    var settingsOpened: Bool = false
    var transcriptMenuOpened: Bool = false

    @ObservationIgnored
    private(set) var horoscopeClient: HoroscopeClient

    private(set) var horoscope: Horoscope.PartiallyGenerated?

    init(horoscopeClient: HoroscopeClient) {
        self.horoscopeClient = horoscopeClient
    }

    func onAppear(username: String?) {
        switch SystemLanguageModel.default.availability {
        case .available:
            horoscopeClient.prewarm(username)
        case .unavailable(let reason):
            overlayState = .unavailable(reason: reason)
        }
    }

    func generate(username: String) {
        settingsOpened = false
        if overlayState == .loading {
            return
        }
        overlayState = .loading
        horoscope = nil
        Task {
            do {
                for try await partialResponse in horoscopeClient.generate(username) {
                    horoscope = partialResponse.content
                    overlayState = .normal
                }
            } catch {
                horoscope = nil
                overlayState = .error(error.localizedDescription)
            }
        }
    }
}

#if DEBUG
extension ContentViewModel {
    static func loading() -> ContentViewModel {
        let vm = ContentViewModel(horoscopeClient: .noop)
        vm.overlayState = .loading
        return vm
    }

    static func withError(_ message: String = "An unexpected error occurred") -> ContentViewModel {
        let vm = ContentViewModel(horoscopeClient: .noop)
        vm.overlayState = .error(message)
        return vm
    }

    static func unavailable() -> ContentViewModel {
        let vm = ContentViewModel(horoscopeClient: .noop)
        vm.overlayState = .unavailable(reason: .appleIntelligenceNotEnabled)
        return vm
    }

    static func withHoroscope() -> ContentViewModel {
        let vm = ContentViewModel(horoscopeClient: .noop)
        let json = #"{"sign": "aries", "message": "Your commits today are as mysterious as a nil pointer exception. Mercury is in retrograde, but your pull requests are aligned with the stars."}"#
        let content = try! GeneratedContent(json: json)
        vm.horoscope = try! .init(content)
        return vm
    }
}
#endif
