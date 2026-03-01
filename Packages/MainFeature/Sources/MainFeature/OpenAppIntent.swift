//
//  Created by Artem Novichkov on 09.08.2025.
//

import AppIntents

#if !os(macOS)
public struct OpenAppIntent: TargetContentProvidingIntent {
    public init() {}
    public static let title: LocalizedStringResource = "Generate a horoscope"
    public static let isDiscoverable = false
    public static let supportedModes: IntentModes = [.foreground]
}
#endif
