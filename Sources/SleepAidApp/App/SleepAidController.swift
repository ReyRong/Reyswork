import Combine
import Foundation

@MainActor
final class SleepAidController: ObservableObject {
    @Published var selectedSoundscape: Soundscape = .rain
    @Published var selectedMinutes = 45
    @Published var customMinutes = 45
    @Published var lastErrorMessage: String?

    let audioPlayer: AudioPlayerService
    let sleepTimer: SleepTimer
    let loginItemService: LoginItemService
    let focusIntegration: FocusIntegrationService

    private var cancellables: Set<AnyCancellable> = []

    init() {
        self.audioPlayer = AudioPlayerService()
        self.sleepTimer = SleepTimer()
        self.loginItemService = LoginItemService()
        self.focusIntegration = FocusIntegrationService()

        wireChildUpdates()
        focusIntegration.configure { [weak self] in
            self?.startDefaultSleepPreset()
        }
    }

    var playbackState: PlaybackState {
        audioPlayer.state
    }

    var volume: Float {
        get { audioPlayer.volume }
        set { audioPlayer.volume = newValue }
    }

    var remainingText: String {
        sleepTimer.isRunning ? sleepTimer.formattedRemaining() : "--:--"
    }

    var menuBarSymbol: String {
        switch playbackState {
        case .playing:
            return "moon.zzz.fill"
        case .paused:
            return "pause.circle"
        case .error:
            return "exclamationmark.triangle"
        case .idle, .preparing:
            return "moon.zzz"
        }
    }

    func startSelectedSession() {
        startSession(soundscape: selectedSoundscape, minutes: selectedMinutes)
    }

    func startCustomSession() {
        let minutes = min(max(customMinutes, 1), 480)
        customMinutes = minutes
        selectedMinutes = minutes
        startSession(soundscape: selectedSoundscape, minutes: minutes)
    }

    func startQuickSession(minutes: Int) {
        selectedMinutes = minutes
        customMinutes = minutes
        startSession(soundscape: selectedSoundscape, minutes: minutes)
    }

    func stopSession(fadeOut: Bool = true) {
        sleepTimer.cancel()
        audioPlayer.stop(fadeOut: fadeOut)
    }

    func pauseOrResume() {
        switch playbackState {
        case .playing:
            audioPlayer.pause()
        case .paused:
            audioPlayer.resume()
        case .idle, .preparing, .error:
            startSelectedSession()
        }
    }

    func activateSleepPresetFromFocus() {
        focusIntegration.activateSleepPreset()
    }

    func setLoginItemEnabled(_ enabled: Bool) {
        loginItemService.setEnabled(enabled)
    }

    private func startSession(soundscape: Soundscape, minutes: Int) {
        lastErrorMessage = nil
        audioPlayer.play(soundscape: soundscape, volume: volume)

        if case let .error(message) = audioPlayer.state {
            sleepTimer.cancel()
            lastErrorMessage = message
            return
        }

        sleepTimer.start(duration: TimeInterval(minutes * 60)) { [weak self] in
            self?.audioPlayer.stop(fadeOut: true)
        }
    }

    private func startDefaultSleepPreset() {
        selectedSoundscape = .rain
        selectedMinutes = 45
        customMinutes = 45
        startSession(soundscape: .rain, minutes: 45)
    }

    private func wireChildUpdates() {
        audioPlayer.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        sleepTimer.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        loginItemService.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        focusIntegration.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
}
