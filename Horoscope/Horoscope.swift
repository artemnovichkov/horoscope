//
//  Created by Artem Novichkov on 27.07.2025.
//

import FoundationModels

@Generable
struct Horoscope: Equatable {

    @Guide(description: "Zodiac sign.")
    let sign: String

    @Guide(description: "Today's horoscope message for the developer. Based on the zodiac sign and user's GitHub information.")
    let message: String
}
