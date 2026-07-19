import Combine
import Foundation

@MainActor
final class SleepAidController: ObservableObject {
    @Published var selectedScene: NoiseScene = .sleep {
        didSet {
            selectedMinutes = selectedScene.defaultMinutes
            customMinutes = selectedScene.defaultMinutes
            keepSelectedSoundscapeAvailable()
        }
    }
    @Published var selectedSoundscape: Soundscape = .rain
    @Published var selectedMinutes = 45
    @Published var customMinutes = 45
    @Published var sceneAssignments = SoundscapeSceneAssignments.defaults
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

    var availableSoundscapes: [Soundscape] {
        sceneAssignments.soundscapes(for: selectedScene)
    }

    var menuBarSymbol: String {
        switch playbackState {
        case .playing:
            return selectedScene.systemImage
        case .paused:
            return "pause.circle"
        case .error:
            return "exclamationmark.triangle"
        case .idle, .preparing:
            return selectedScene.systemImage
        }
    }

    func startSelectedSession() {
        let soundscape = nextSoundscape(for: selectedScene)
        selectedSoundscape = soundscape
        startSession(soundscape: soundscape, minutes: selectedMinutes)
    }

    func startCustomSession() {
        let minutes = min(max(customMinutes, 1), 480)
        customMinutes = minutes
        selectedMinutes = minutes
        let soundscape = nextSoundscape(for: selectedScene)
        selectedSoundscape = soundscape
        startSession(soundscape: soundscape, minutes: minutes)
    }

    func startQuickSession(minutes: Int) {
        selectedMinutes = minutes
        customMinutes = minutes
        let soundscape = nextSoundscape(for: selectedScene)
        selectedSoundscape = soundscape
        startSession(soundscape: soundscape, minutes: minutes)
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
        selectedScene = .sleep
        focusIntegration.activateSleepPreset()
    }

    func setLoginItemEnabled(_ enabled: Bool) {
        loginItemService.setEnabled(enabled)
    }

    func setSceneAssignment(_ soundscape: Soundscape, enabled: Bool, for scene: NoiseScene) {
        sceneAssignments.set(soundscape, enabled: enabled, for: scene)
        keepSelectedSoundscapeAvailable()
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
        selectedScene = .sleep
        let soundscape = nextSoundscape(for: .sleep)
        selectedSoundscape = .rain
        selectedMinutes = 45
        customMinutes = 45
        selectedSoundscape = soundscape
        startSession(soundscape: soundscape, minutes: 45)
    }

    private func nextSoundscape(for scene: NoiseScene) -> Soundscape {
        let available = sceneAssignments.soundscapes(for: scene)

        if scene == .focus, available.contains(selectedSoundscape) {
            return selectedSoundscape
        }

        return available.randomElement() ?? .rain
    }

    private func keepSelectedSoundscapeAvailable() {
        let available = availableSoundscapes
        guard !available.contains(selectedSoundscape), let firstAvailable = available.first else {
            return
        }
        selectedSoundscape = firstAvailable
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
