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

    func testShortcutCanSetUnlimitedDuration() {
        let userDefaults = UserDefaults(suiteName: "SleepAidControllerTests-\(UUID().uuidString)")!
        let controller = SleepAidController(settingsStore: AppSettingsStore(userDefaults: userDefaults))

        let response = controller.handleShortcutCommand(.setDuration(minutes: 0))

        XCTAssertEqual(controller.selectedMinutes, 0)
        XCTAssertEqual(controller.customMinutes, 0)
        XCTAssertEqual(response.dialog, "已设置为不限时")
    }
}
