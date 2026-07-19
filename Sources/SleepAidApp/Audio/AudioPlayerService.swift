@preconcurrency import AVFoundation
import Foundation

enum AudioPlayerError: LocalizedError, Equatable {
    case resourceMissing(Soundscape)
    case unsupportedFormat(Soundscape)
    case playbackFailed(String)

    var errorDescription: String? {
        switch self {
        case let .resourceMissing(soundscape):
            return "还没有找到「\(soundscape.displayName)」的音频文件。请把 \(soundscape.assetBaseName).m4a 或 .wav 放入 Resources/Audio。"
        case let .unsupportedFormat(soundscape):
            return "「\(soundscape.displayName)」的音频格式暂不支持。请使用 m4a 或 wav。"
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
    private var retiredPlayers: [AVAudioPlayer] = []

    deinit {
        fadeTimer?.invalidate()
        player?.stop()
        retiredPlayers.forEach { $0.stop() }
    }

    func play(soundscape: Soundscape, volume: Float, fadeInDuration: TimeInterval = 1.5) {
        self.volume = min(max(volume, 0), 1)
        fadeTimer?.invalidate()
        state = .preparing

        do {
            let url = try AudioResourceResolver.url(for: soundscape)
            let nextPlayer = try AVAudioPlayer(contentsOf: url)
            retireCurrentPlayer()
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
            state = .error(AudioPlayerError.unsupportedFormat(soundscape).localizedDescription)
        }
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
        retiredPlayers.forEach { $0.stop() }
        retiredPlayers.removeAll()
        state = .idle
    }

    private func retireCurrentPlayer() {
        guard let player else {
            return
        }

        retiredPlayers.append(player)
        fade(player: player, to: 0, duration: 1.2) { [weak self, weak player] in
            player?.stop()
            self?.retiredPlayers.removeAll { $0 === player }
        }
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

    private func fade(player: AVAudioPlayer, to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard duration > 0 else {
            player.volume = targetVolume
            completion?()
            return
        }

        let startVolume = player.volume
        let startDate = Date()
        let interval = 1.0 / 30.0

        let newTimer = Timer(timeInterval: interval, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startDate)
            let progress = min(1, elapsed / duration)
            player.volume = startVolume + (targetVolume - startVolume) * Float(progress)

            if progress >= 1 {
                timer.invalidate()
                completion?()
            }
        }

        RunLoop.main.add(newTimer, forMode: .common)
    }
}
