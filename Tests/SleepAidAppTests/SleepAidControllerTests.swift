import XCTest
@testable import SleepAidApp

@MainActor
final class SleepAidControllerTests: XCTestCase {
    func testSelectingPresetDurationSyncsCustomDuration() {
        let userDefaults = UserDefaults(suiteName: "SleepAidControllerTests-\(UUID().uuidString)")!
        let controller = SleepAidController(settingsStore: AppSettingsStore(userDefaults: userDefaults))

        controller.customMinutes = 75
        controller.selectedMinutes = 20

        XCTAssertEqual(controller.customMinutes, 20)
    }

    func testStartSleepShortcutUsesCurrentSleepSoundscape() {
        let userDefaults = UserDefaults(suiteName: "SleepAidControllerTests-\(UUID().uuidString)")!
        let controller = SleepAidController(settingsStore: AppSettingsStore(userDefaults: userDefaults))

        controller.selectedScene = .sleep
        controller.selectedSoundscape = .ocean

        let response = controller.handleShortcutCommand(.startSleep)

        XCTAssertEqual(controller.selectedScene, .sleep)
        XCTAssertEqual(controller.selectedSoundscape, .ocean)
        XCTAssertEqual(response.dialog, "已开始助眠白噪音")
    }

    func testRandomSleepShortcutUsesSleepPool() {
        let userDefaults = UserDefaults(suiteName: "SleepAidControllerTests-\(UUID().uuidString)")!
        let controller = SleepAidController(settingsStore: AppSettingsStore(userDefaults: userDefaults))

        controller.selectedScene = .sleep
        controller.setSceneAssignment(.rain, enabled: false, for: .sleep)
        controller.setSceneAssignment(.fireplace, enabled: false, for: .sleep)
        controller.setSceneAssignment(.summerNight, enabled: false, for: .sleep)

        let response = controller.handleShortcutCommand(.startSleepRandom)

        XCTAssertEqual(controller.selectedScene, .sleep)
        XCTAssertEqual(controller.selectedSoundscape, .ocean)
        XCTAssertEqual(response.dialog, "已随机播放助眠白噪音")
    }

    func testTogglePauseShortcutDoesNotStartIdlePlayback() {
        let userDefaults = UserDefaults(suiteName: "SleepAidControllerTests-\(UUID().uuidString)")!
        let controller = SleepAidController(settingsStore: AppSettingsStore(userDefaults: userDefaults))

        let response = controller.handleShortcutCommand(.togglePause)

        XCTAssertEqual(response.dialog, "当前没有正在播放的白噪音")
        XCTAssertEqual(controller.playbackState, .idle)
    }

    func testShortcutURLRoutesToControllerCommand() {
        let userDefaults = UserDefaults(suiteName: "SleepAidControllerTests-\(UUID().uuidString)")!
        let controller = SleepAidController(settingsStore: AppSettingsStore(userDefaults: userDefaults))

        let response = controller.handleShortcutURL(URL(string: "whitenoise://shortcut/status")!)

        XCTAssertEqual(response?.dialog, "未播放")
    }

    func testPreparingForTerminationStoresIdleShortcutStatus() {
        let userDefaults = UserDefaults(suiteName: "SleepAidControllerTests-\(UUID().uuidString)")!
        let statusStore = ShortcutStatusStore(userDefaults: userDefaults)
        let controller = SleepAidController(
            settingsStore: AppSettingsStore(userDefaults: userDefaults),
            shortcutStatusStore: statusStore
        )

        _ = controller.handleShortcutCommand(.startSleep)
        XCTAssertEqual(statusStore.load(), "正在播放")

        controller.prepareForTermination()

        XCTAssertEqual(statusStore.load(), "未播放")
    }
}
