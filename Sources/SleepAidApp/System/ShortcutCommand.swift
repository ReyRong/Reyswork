import Foundation

enum ShortcutCommand: Equatable {
    case start(scene: NoiseScene)
    case pause
    case resume
    case stop
    case switchSoundscape(Soundscape)
    case setDuration(minutes: Int)
    case queryStatus

    var clampedMinutes: Int? {
        guard case let .setDuration(minutes) = self else {
            return nil
        }

        if minutes == 0 {
            return 0
        }

        return min(max(minutes, 1), 480)
    }
}

struct ShortcutSessionSnapshot: Equatable {
    let scene: NoiseScene
    let soundscape: Soundscape
    let playbackState: PlaybackState
    let remainingText: String
    let selectedMinutes: Int
    let volume: Float

    var summary: String {
        [
            scene.displayName,
            soundscape.displayName,
            playbackState.shortcutDisplayName,
            remainingPhrase,
            "音量 \(Int((volume * 100).rounded()))%"
        ]
        .joined(separator: " · ")
    }

    private var remainingPhrase: String {
        if selectedMinutes == 0 {
            return "不限时"
        }

        return "剩余 \(remainingText)"
    }
}

struct ShortcutCommandResponse: Equatable {
    let dialog: String
    let snapshot: ShortcutSessionSnapshot
}

extension PlaybackState {
    var shortcutDisplayName: String {
        switch self {
        case .idle:
            return "待机"
        case .preparing:
            return "准备中"
        case .playing:
            return "播放中"
        case .paused:
            return "已暂停"
        case .error:
            return "出错"
        }
    }
}
