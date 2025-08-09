//
//  Created by Artem Novichkov on 09.08.2025.
//

import SwiftUI
import WidgetKit
import AppIntents

/// A widget that provides quick access to the Horoscope feature of the app.
///
/// Displays a control  that opens the main Horoscope screen in the app.
struct HoroscopeControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "HoroscopeControlWidget") {
            ControlWidgetButton(action: OpenAppIntent()) {
                Image(systemName: "wand.and.sparkles")
            }
        }
        .displayName(LocalizedStringResource.openHoroscope)
    }
}
