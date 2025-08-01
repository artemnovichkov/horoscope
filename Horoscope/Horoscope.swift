//
//  Created by Artem Novichkov on 27.07.2025.
//

import FoundationModels

/// A structure representing a developer's daily horoscope based on their zodiac sign and GitHub information.
/// 
/// - Parameters:
///   - sign: The user's zodiac sign.
///   - message: The daily horoscope message tailored for the developer, generated using the zodiac sign and the user's GitHub profile.
@Generable
struct Horoscope: Equatable {

    @Guide(description: "Zodiac sign.")
    let sign: String

    @Guide(description: "Today's horoscope message for the developer. Based on the zodiac sign and user's GitHub information.")
    let message: String
}
