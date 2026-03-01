//
//  Created by Artem Novichkov on 30.07.2025.
//

import TipKit

/// A tip that encourages the user to share their horoscope.
struct ShareTip: Tip {
    let title = Text(.sharingTipTitle)
    let message: Text? = Text(.shareTipMessage)
}

/// A tip that helps the user understand or input their GitHub username.
struct UsernameTip: Tip {
    let title = Text(.usernameTipTitle)
    let message: Text? = Text(.usernameTipMessage)
}
