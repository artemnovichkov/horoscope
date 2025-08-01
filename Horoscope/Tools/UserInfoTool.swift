//
//  Created by Artem Novichkov on 26.07.2025.
//

import FoundationModels
import HealthKit
import ZodiacKit

/// A tool that retrieves the user's zodiac sign and gender using HealthKit data.
///
/// This tool accesses the HealthKit store to fetch the user's date of birth and biological sex.
/// It uses `ZodiacKit` to determine the zodiac sign based on the birth date.
///
/// The tool is only functional on iOS and requires user authorization to access HealthKit data.
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
    struct Arguments {}

    private lazy var healthStore = HKHealthStore()
    private lazy var zodiacService = ZodiacService()

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

    // MARK: - Private

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
