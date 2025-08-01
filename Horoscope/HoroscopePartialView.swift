//
//  Created by Artem Novichkov on 28.07.2025.
//

import SwiftUI
import ZodiacKit
import FoundationModels


/// A SwiftUI view that displays a partially generated horoscope.
///
/// This view conditionally renders a user's zodiac sign and horoscope message.
struct HoroscopePartialView: View {

    var horoscope: Horoscope.PartiallyGenerated?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let sign = horoscope?.sign, let zodiacSign = Western(rawValue: sign.lowercased()) {
                Text(.yourHoroscopeSign)
                    .font(.headline)
                Text(zodiacSign.emoji + " " + zodiacSign.name)
                    .font(.largeTitle.bold())
                    .transition(.opacity)
            }
            if let message = horoscope?.message {
                Text(message)
                    .font(.body)
                    .transition(.opacity)
                    .textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let jsons = [
        #"{"sign": "aries"#,
        #"{"sign": "aries", "message": "message"#
    ]
    VStack {
        ForEach(jsons, id: \.self) { json in
            let content = try! GeneratedContent(json: json)
            HoroscopePartialView(horoscope: try! .init(content))
        }
    }
}

