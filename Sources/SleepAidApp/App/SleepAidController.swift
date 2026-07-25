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
    @Published var selectedMinutes = 45 {
        didSet {
            syncCustomMinutesWithSelectedPreset()
            saveSettings()
        }
    }
    @Published var customMinutes = 45 { didSet { saveSettings() } }
    @Published var sceneAssignments = SoundscapeSceneAssignments.defaults { didSet { saveSettings() } }
    @Published var lastErrorMessage: String?

    let audioPlayer: AudioPlayerService
    let sleepTimer: SleepTimer
    let loginItemService: LoginItemService
    let focusIntegration: FocusIntegrationService

    private let settingsStore: AppSettingsStore
    private let shortcutStatusStore: ShortcutStatusStore
    private var isRestoringSettings = false
    private var cancellables: Set<AnyCancellable> = []

    init(
        settingsStore: AppSettingsStore = AppSettingsStore(),
        shortcutStatusStore: ShortcutStatusStore = ShortcutStatusStore()
    ) {
        self.settingsStore = settingsStore
        self.shortcutStatusStore = shortcutStatusStore
        self.audioPlayer = AudioPlayerService()
        self.sleepTimer = SleepTimer()
        self.loginItemService = LoginItemService()
        self.focusIntegration = FocusIntegrationService()

        restoreSettings()
        wireChildUpdates()
        focusIntegration.configure { [weak self] in
            self?.startDefaultSleepPreset()
        }
        saveShortcutStatus()
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
        return sleepTimer.isRunning || sleepTimer.isPaused ? sleepTimer.formattedRemaining() : "--:--"
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

    func handleShortcutCommand(_ command: ShortcutCommand) -> ShortcutCommandResponse {
        let dialog: String

        switch command {
        case .startSleep:
            selectedScene = .sleep
            let soundscape = currentSoundscape(for: .sleep)
            selectedSoundscape = soundscape
            startSession(soundscape: soundscape, minutes: selectedMinutes)
            dialog = "已开始助眠白噪音"
        case .startSleepRandom:
            selectedScene = .sleep
            let soundscape = nextSoundscape(for: .sleep)
            selectedSoundscape = soundscape
            startSession(soundscape: soundscape, minutes: selectedMinutes)
            dialog = "已随机播放助眠白噪音"
        case .togglePause:
            if playbackState == .paused {
                resumeSession()
                dialog = "已继续白噪音"
            } else if playbackState.isActive {
                pauseSession()
                dialog = "已暂停白噪音"
            } else {
                dialog = "当前没有正在播放的白噪音"
            }
        case .stop:
            stopSession(fadeOut: false)
            dialog = "已停止白噪音"
        case .queryStatus:
            dialog = currentShortcutSnapshot.summary
        }

        saveShortcutStatus()
        return ShortcutCommandResponse(dialog: dialog, snapshot: currentShortcutSnapshot)
    }

    func handleShortcutURL(_ url: URL) -> ShortcutCommandResponse? {
        guard let command = ShortcutURLCommand(url: url) else {
            return nil
        }

        return handleShortcutCommand(command.shortcutCommand)
    }

    func prepareForTermination() {
        stopSession(fadeOut: false)
        saveShortcutStatus()
    }

    var currentShortcutSnapshot: ShortcutSessionSnapshot {
        ShortcutSessionSnapshot(
            scene: selectedScene,
            soundscape: selectedSoundscape,
            playbackState: playbackState,
            remainingText: remainingText,
            selectedMinutes: selectedMinutes,
            volume: volume
        )
    }

    private func startSession(soundscape: Soundscape, minutes: Int) {
        lastErrorMessage = nil
        audioPlayer.play(soundscape: soundscape, volume: volume)
        saveShortcutStatus()

        if case let .error(message) = audioPlayer.state {
            sleepTimer.cancel()
            lastErrorMessage = message
            saveShortcutStatus()
            return
        }

        if minutes > 0 {
            sleepTimer.start(duration: TimeInterval(minutes * 60)) { [weak self] in
                self?.audioPlayer.stop(fadeOut: true)
            }
        } else {
            sleepTimer.cancel()
        }
        saveShortcutStatus()
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

    private func syncCustomMinutesWithSelectedPreset() {
        guard customMinutes != selectedMinutes else {
            return
        }
        customMinutes = selectedMinutes
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
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.saveShortcutStatus()
            }
            .store(in: &cancellables)

        sleepTimer.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.saveShortcutStatus()
            }
            .store(in: &cancellables)

        loginItemService.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        focusIntegration.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    private func saveShortcutStatus() {
        shortcutStatusStore.save(currentShortcutSnapshot.summary)
    }
}
