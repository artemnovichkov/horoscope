//
//  Created by Artem Novichkov on 09.08.2025.
//

import AppIntents

struct OpenAppIntent: TargetContentProvidingIntent {
    static var title: LocalizedStringResource = "Generate a horoscope"
    static var isDiscoverable = false
    static var supportedModes: IntentModes = [.foreground]
}
