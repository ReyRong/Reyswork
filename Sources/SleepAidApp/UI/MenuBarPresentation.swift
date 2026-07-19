import Foundation

struct MenuBarPresentation {
    let scene: NoiseScene
    let soundscape: Soundscape
    let playbackState: PlaybackState
    let remainingText: String

    var symbolName: String {
        switch playbackState {
        case .playing:
            return "waveform.circle.fill"
        case .paused:
            return "pause.circle"
        case .error:
            return "exclamationmark.triangle"
        case .idle, .preparing:
            return "waveform.circle"
        }
    }

    var title: String {
        "\(scene.displayName) · \(soundscape.displayName)"
    }

    var subtitle: String {
        "\(statusText) · \(remainingText)"
    }

    var statusText: String {
        switch playbackState {
        case .idle:
            return "待机"
        case .preparing:
            return "准备"
        case .playing:
            return "播放中"
        case .paused:
            return "暂停"
        case .error:
            return "需要音频"
        }
    }
}
