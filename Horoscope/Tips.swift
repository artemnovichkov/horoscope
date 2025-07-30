//
//  Created by Artem Novichkov on 30.07.2025.
//

import TipKit

struct ShareTip: Tip {
    let title = Text(.sharingTipTitle)
    let message: Text? = Text(.shareTipMessage)
}

struct UsernameTip: Tip {
    let title = Text(.usernameTipTitle)
    let message: Text? = Text(.usernameTipMessage)
}
