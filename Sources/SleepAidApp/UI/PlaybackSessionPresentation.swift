import Foundation

struct PlaybackSessionPresentation {
    let selectedMinutes: Int
    let remainingText: String
    let currentTimeText: String

    var isUnlimited: Bool {
        selectedMinutes == 0
    }

    var centralText: String {
        isUnlimited ? currentTimeText : remainingText
    }

    var showsCornerClock: Bool {
        !isUnlimited
    }
}
