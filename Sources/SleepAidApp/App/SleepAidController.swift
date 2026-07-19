import Combine
import Foundation

@MainActor
final class SleepAidController: ObservableObject {
    @Published var selectedScene: NoiseScene = .sleep {
        didSet {
            selectedMinutes = selectedScene.defaultMinutes
            customMinutes = selectedScene.defaultMinutes
            keepSelectedSoundscapeAvailable()
            saveSettings()
        }
    }
    @Published var selectedSoundscape: Soundscape = .rain { didSet { saveSettings() } }
    @Published var selectedMinutes = 45 { didSet { saveSettings() } }
    @Published var customMinutes = 45 { didSet { saveSettings() } }
    @Published var sceneAssignments = SoundscapeSceneAssignments.defaults { didSet { saveSettings() } }
    @Published var lastErrorMessage: String?

    let audioPlayer: AudioPlayerService
    let sleepTimer: SleepTimer
    let loginItemService: LoginItemService
    let focusIntegration: FocusIntegrationService

    private let settingsStore: AppSettingsStore
    private var isRestoringSettings = false
    private var cancellables: Set<AnyCancellable> = []

    init(settingsStore: AppSettingsStore = AppSettingsStore()) {
        self.settingsStore = settingsStore
        self.audioPlayer = AudioPlayerService()
        self.sleepTimer = SleepTimer()
        self.loginItemService = LoginItemService()
        self.focusIntegration = FocusIntegrationService()

        restoreSettings()
        wireChildUpdates()
        focusIntegration.configure { [weak self] in
            self?.startDefaultSleepPreset()
        }
        ShortcutRequestCenter.shared.configure { [weak self] scene in
            self?.chooseScene(scene)
            self?.startQuickSession(minutes: scene.defaultMinutes)
        }
    }

    var playbackState: PlaybackState {
        audioPlayer.state
    }

    var volume: Float {
        get { audioPlayer.volume }
        set {
            audioPlayer.volume = newValue
            saveSettings()
        }
    }

    var remainingText: String {
        if selectedScene == .focus, selectedMinutes == 0, playbackState.isActive {
            return "不限时"
        }
        return sleepTimer.isRunning ? sleepTimer.formattedRemaining() : "--:--"
    }

    var availableSoundscapes: [Soundscape] {
        sceneAssignments.soundscapes(for: selectedScene)
    }

    var menuBarSymbol: String {
        menuBarPresentation.symbolName
    }

    var menuBarPresentation: MenuBarPresentation {
        MenuBarPresentation(
            scene: selectedScene,
            soundscape: selectedSoundscape,
            playbackState: playbackState,
            remainingText: remainingText
        )
    }

    func startSelectedSession() {
        let soundscape = currentSoundscape(for: selectedScene)
        selectedSoundscape = soundscape
        startSession(soundscape: soundscape, minutes: selectedMinutes)
    }

    func chooseScene(_ scene: NoiseScene) {
        selectedScene = scene
        if playbackState.isActive {
            startSelectedSession()
        }
    }

    func chooseSoundscape(_ soundscape: Soundscape) {
        selectedSoundscape = soundscape
        if playbackState.isActive {
            startSession(soundscape: soundscape, minutes: selectedMinutes)
        }
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

    func pauseSession() {
        audioPlayer.pause()
        sleepTimer.pause()
    }

    func resumeSession() {
        audioPlayer.resume()
        sleepTimer.resume()
    }

    func setUnlimitedFocusEnabled(_ enabled: Bool) {
        guard selectedScene == .focus else {
            return
        }

        if enabled {
            selectedMinutes = 0
            customMinutes = 0
        } else {
            selectedMinutes = NoiseScene.focus.defaultMinutes
            customMinutes = NoiseScene.focus.defaultMinutes
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

        if minutes > 0 {
            sleepTimer.start(duration: TimeInterval(minutes * 60)) { [weak self] in
                self?.audioPlayer.stop(fadeOut: true)
            }
        } else {
            sleepTimer.cancel()
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
        SoundscapeSelector.select(for: scene, current: selectedSoundscape, assignments: sceneAssignments)
    }

    private func currentSoundscape(for scene: NoiseScene) -> Soundscape {
        SoundscapeSelector.selectCurrent(for: scene, current: selectedSoundscape, assignments: sceneAssignments)
    }

    private func keepSelectedSoundscapeAvailable() {
        let available = availableSoundscapes
        guard !available.contains(selectedSoundscape), let firstAvailable = available.first else {
            return
        }
        selectedSoundscape = firstAvailable
    }

    private func restoreSettings() {
        isRestoringSettings = true
        let settings = settingsStore.load()
        selectedScene = settings.selectedScene
        selectedSoundscape = settings.selectedSoundscape
        selectedMinutes = settings.selectedMinutes
        customMinutes = settings.customMinutes
        sceneAssignments = settings.sceneAssignments
        volume = settings.volume
        keepSelectedSoundscapeAvailable()
        isRestoringSettings = false
    }

    private func saveSettings() {
        guard !isRestoringSettings else {
            return
        }
        settingsStore.save(
            AppSettings(
                selectedScene: selectedScene,
                selectedSoundscape: selectedSoundscape,
                selectedMinutes: selectedMinutes,
                customMinutes: customMinutes,
                volume: volume,
                sceneAssignments: sceneAssignments
            )
        )
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
