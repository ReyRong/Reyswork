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
}
