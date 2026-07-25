import Foundation

enum ShortcutCommand: Equatable {
    case startSleep
    case startSleepRandom
    case togglePause
    case stop
    case queryStatus
}

struct ShortcutSessionSnapshot: Equatable {
    let scene: NoiseScene
    let soundscape: Soundscape
    let playbackState: PlaybackState
    let remainingText: String
    let selectedMinutes: Int
    let volume: Float

    var summary: String {
        playbackState.shortcutDisplayName
    }
}

struct ShortcutCommandResponse: Equatable {
    let dialog: String
    let snapshot: ShortcutSessionSnapshot
}

extension PlaybackState {
    var shortcutDisplayName: String {
        switch self {
        case .idle, .error:
            return "未播放"
        case .preparing, .playing:
            return "正在播放"
        case .paused:
            return "已暂停"
        }
    }
}
