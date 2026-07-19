import XCTest
@testable import SleepAidApp

final class AppSettingsStoreTests: XCTestCase {
    func testSaveAndLoadRoundTripsUserScenePreferences() throws {
        let suiteName = "AppSettingsStoreTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = AppSettingsStore(userDefaults: defaults)
        let settings = AppSettings(
            selectedScene: .focus,
            selectedSoundscape: .library,
            selectedMinutes: 90,
            customMinutes: 75,
            volume: 0.32,
            sceneAssignments: SoundscapeSceneAssignments(
                mapping: [
                    .ocean: [.sleep],
                    .fireplace: [.sleep],
                    .rain: [.sleep],
                    .summerNight: [.sleep],
                    .cafe: [.focus],
                    .library: [.focus]
                ]
            )
        )

        store.save(settings)

        XCTAssertEqual(store.load(), settings)
    }

    func testLoadFallsBackToDefaultsWhenNoSettingsExist() throws {
        let suiteName = "AppSettingsStoreTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = AppSettingsStore(userDefaults: defaults)

        XCTAssertEqual(store.load(), .defaults)
    }

    func testFocusSettingsAllowUnlimitedDuration() throws {
        let suiteName = "AppSettingsStoreTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = AppSettingsStore(userDefaults: defaults)
        var settings = AppSettings.defaults
        settings.selectedScene = .focus
        settings.selectedSoundscape = .library
        settings.selectedMinutes = 0
        settings.customMinutes = 0

        store.save(settings)

        XCTAssertEqual(store.load().selectedMinutes, 0)
        XCTAssertEqual(store.load().customMinutes, 0)
    }
}
