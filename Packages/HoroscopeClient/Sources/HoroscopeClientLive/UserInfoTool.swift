import FoundationModels
import HealthKit
import ZodiacKit

@MainActor
final class UserInfoTool: Tool {
    enum Error: Swift.Error, LocalizedError {
        case healthDataNotAvailable

        var errorDescription: String? {
            switch self {
            case .healthDataNotAvailable:
                "Health data is not available on this device"
            }
        }
    }

    let name = "fetchUserInfo"
    let description = "Get zodiac sign and gender for user"

    @Generable
    struct Arguments: Sendable {}

    private let healthStore = HKHealthStore()
    private let zodiacService = ZodiacService()

    private let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
    private let biologicalSexType = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!

    func call(arguments: Arguments) async throws -> GeneratedContent {
        #if os(iOS)
        guard HKHealthStore.isHealthDataAvailable() else {
            throw Error.healthDataNotAvailable
        }
        try await healthStore.requestAuthorization(toShare: [], read: [dateOfBirthType, biologicalSexType])
        return try GeneratedContent(properties: [
            "sign": zodiacSign(),
            "gender": gender(),
        ])
        #else
        return GeneratedContent(properties: [:])
        #endif
    }

    private func zodiacSign() throws -> String? {
        let dateOfBirthComponents = try healthStore.dateOfBirthComponents()
        guard let birthDate = Calendar.current.date(from: dateOfBirthComponents) else {
            return nil
        }
        return try zodiacService.getWesternZodiac(from: birthDate).name.lowercased()
    }

    private func gender() throws -> String {
        switch try healthStore.biologicalSex().biologicalSex {
        case .notSet: "Not Set"
        case .female: "Female"
        case .male: "Male"
        case .other: "Other"
        @unknown default: "Unknown"
        }
    }
}
