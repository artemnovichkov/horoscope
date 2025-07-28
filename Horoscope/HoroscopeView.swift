//
//  Created by Artem Novichkov on 27.07.2025.
//

import SwiftUI
import ZodiacKit

struct HoroscopeView: View {

    let horoscope: Horoscope

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let zodiacSign = Western(rawValue: horoscope.sign.lowercased()) {
                Text(.yourHoroscopeSign)
                    .font(.headline)
                Text(zodiacSign.emoji + " " + zodiacSign.name)
                    .font(.largeTitle.bold())
            }
            Text(horoscope.message)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

#Preview {
    HoroscopeView(horoscope: Horoscope(sign: "aries", message: "Test message"))
}
