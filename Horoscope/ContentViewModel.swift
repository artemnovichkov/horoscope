//
//  Created by Artem Novichkov on 27.07.2025.
//

import Foundation
import SwiftUI
import FoundationModels

@Observable
final class ContentViewModel {
    private(set) var unavailableReason: SystemLanguageModel.Availability.UnavailableReason?
    private(set) var isLoading = false
    private(set) var error: Error?


    @ObservationIgnored
    private var service: HoroscopeService = HoroscopeService()

    private(set) var horoscope: Horoscope.PartiallyGenerated?

    func onAppear() {
        switch SystemLanguageModel.default.availability {
        case .available:
            service.prewarm()
        case .unavailable(let reason):
            unavailableReason = reason
        }
    }

    @MainActor func generate(username: String) {
        Task {
            isLoading = true
            do {
                horoscope = nil
                error = nil
                for try await partialResponse in service.horoscopeStream(username: username) {
                    horoscope = partialResponse
                }
            } catch {
                horoscope = nil
                self.error = error
            }
            isLoading = false
        }
    }
}
