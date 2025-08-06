//
//  Created by Artem Novichkov on 27.07.2025.
//

import Foundation
import SwiftUI
import FoundationModels

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
    private(set) var service: HoroscopeService = HoroscopeService()

    private(set) var horoscope: Horoscope.PartiallyGenerated?

    func onAppear(username: String?) {
        switch SystemLanguageModel.default.availability {
        case .available:
            service.prewarm(username: username)
        case .unavailable(let reason):
            overlayState = .unavailable(reason: reason)
        }
    }

    @MainActor func generate(username: String) {
        settingsOpened = false
        if overlayState == .loading {
            return
        }
        overlayState = .loading
        horoscope = nil
        Task {
            do {
                for try await partialResponse in service.horoscopeStream(username: username) {
                    horoscope = partialResponse.content
                    overlayState = .normal
                }
            } catch {
                overlayState = .error(error.localizedDescription)
            }
        }
    }
}
