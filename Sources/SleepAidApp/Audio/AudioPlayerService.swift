import AVFoundation
import Foundation

enum AudioPlayerError: LocalizedError, Equatable {
    case resourceMissing(Soundscape)
    case playbackFailed(String)

    var errorDescription: String? {
        switch self {
        case let .resourceMissing(soundscape):
            return "还没有找到「\(soundscape.displayName)」的音频文件。请把 \(soundscape.assetBaseName).m4a 或 .wav 放入 Resources/Audio。"
        case let .playbackFailed(message):
            return "音频播放失败：\(message)"
        }
    }
}

@MainActor
final class AudioPlayerService: NSObject, ObservableObject {
    @Published private(set) var state: PlaybackState = .idle
    @Published var volume: Float = 0.55 {
        didSet {
            player?.volume = volume
        }
    }

    private var player: AVAudioPlayer?
    private var fadeTimer: Timer?

    deinit {
        fadeTimer?.invalidate()
        player?.stop()
    }

    func play(soundscape: Soundscape, volume: Float, fadeInDuration: TimeInterval = 1.5) {
        self.volume = min(max(volume, 0), 1)
        fadeTimer?.invalidate()
        state = .preparing

        do {
            let url = try resourceURL(for: soundscape)
            let nextPlayer = try AVAudioPlayer(contentsOf: url)
            nextPlayer.numberOfLoops = -1
            nextPlayer.volume = 0
            nextPlayer.prepareToPlay()
            nextPlayer.play()

            player = nextPlayer
            state = .playing
            fade(to: self.volume, duration: fadeInDuration)
        } catch let error as AudioPlayerError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error(AudioPlayerError.playbackFailed(error.localizedDescription).localizedDescription)
        }
    }

    func pause() {
        guard let player, player.isPlaying else {
            return
        }
        fadeTimer?.invalidate()
        player.pause()
        state = .paused
    }

    func resume() {
        guard let player else {
            return
        }
        fadeTimer?.invalidate()
        player.play()
        state = .playing
    }

    func stop(fadeOut: Bool = true, fadeOutDuration: TimeInterval = 8) {
        guard player != nil else {
            state = .idle
            return
        }

        if fadeOut {
            fade(to: 0, duration: fadeOutDuration) { [weak self] in
                self?.finishStop()
            }
        } else {
            finishStop()
        }
    }

    private func finishStop() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        player?.stop()
        player = nil
        state = .idle
    }

    private func resourceURL(for soundscape: Soundscape) throws -> URL {
        for fileExtension in ["m4a", "wav"] {
            if let url = Bundle.module.url(
                forResource: soundscape.assetBaseName,
                withExtension: fileExtension,
                subdirectory: "Audio"
            ) {
                return url
            }
        }

        throw AudioPlayerError.resourceMissing(soundscape)
    }

    private func fade(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()

        guard let player, duration > 0 else {
            player?.volume = targetVolume
            completion?()
            return
        }

        let startVolume = player.volume
        let startDate = Date()
        let interval = 1.0 / 30.0

        let newTimer = Timer(timeInterval: interval, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self, let player = self.player else {
                    timer.invalidate()
                    return
                }

                let elapsed = Date().timeIntervalSince(startDate)
                let progress = min(1, elapsed / duration)
                player.volume = startVolume + (targetVolume - startVolume) * Float(progress)

                if progress >= 1 {
                    timer.invalidate()
                    self.fadeTimer = nil
                    completion?()
                }
            }
        }

        fadeTimer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)
    }
}
