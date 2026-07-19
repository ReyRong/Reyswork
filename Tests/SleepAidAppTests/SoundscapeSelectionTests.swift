import XCTest
@testable import SleepAidApp

final class SoundscapeSelectionTests: XCTestCase {
    func testSleepSelectionUsesOnlySleepPool() {
        let assignments = SoundscapeSceneAssignments(
            mapping: [
                .ocean: [.sleep],
                .fireplace: [.sleep],
                .rain: [],
                .summerNight: [],
                .cafe: [.focus],
                .library: [.focus]
            ]
        )

        let selected = SoundscapeSelector.select(
            for: .sleep,
            current: .cafe,
            assignments: assignments,
            randomIndex: { count in count - 1 }
        )

        XCTAssertEqual(selected, .fireplace)
    }

    func testFocusSelectionPrefersCurrentFocusSoundscape() {
        let selected = SoundscapeSelector.select(
            for: .focus,
            current: .library,
            assignments: .defaults,
            randomIndex: { _ in 0 }
        )

        XCTAssertEqual(selected, .library)
    }

    func testFocusSelectionFallsBackToFocusPoolWhenCurrentIsUnavailable() {
        let selected = SoundscapeSelector.select(
            for: .focus,
            current: .ocean,
            assignments: .defaults,
            randomIndex: { _ in 0 }
        )

        XCTAssertEqual(selected, .rain)
    }
}
