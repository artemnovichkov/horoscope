//
//  Created by Artem Novichkov on 28.07.2025.
//

import SwiftUI
import ZodiacKit
import FoundationModels

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
    let json = #"{"sign": "aries"#
    let content = try! GeneratedContent(json: json)
    HoroscopePartialView(horoscope: try! .init(content))
}

