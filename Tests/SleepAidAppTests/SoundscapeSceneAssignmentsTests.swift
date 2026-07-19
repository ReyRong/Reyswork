import XCTest
@testable import SleepAidApp

final class SoundscapeSceneAssignmentsTests: XCTestCase {
    func testDefaultAssignmentsKeepEveryScenePlayable() {
        let assignments = SoundscapeSceneAssignments.defaults

        XCTAssertFalse(assignments.soundscapes(for: .sleep).isEmpty)
        XCTAssertFalse(assignments.soundscapes(for: .focus).isEmpty)
    }

    func testTogglingSceneUpdatesSoundscapeAvailability() {
        var assignments = SoundscapeSceneAssignments.defaults

        assignments.set(.fireplace, enabled: false, for: .sleep)

        XCTAssertFalse(assignments.scenes(for: .fireplace).contains(.sleep))
        XCTAssertFalse(assignments.soundscapes(for: .sleep).contains(.fireplace))

        assignments.set(.fireplace, enabled: true, for: .focus)

        XCTAssertTrue(assignments.scenes(for: .fireplace).contains(.focus))
        XCTAssertTrue(assignments.soundscapes(for: .focus).contains(.fireplace))
    }

    func testCannotRemoveLastSoundscapeFromScene() {
        var assignments = SoundscapeSceneAssignments(
            mapping: [
                .rain: [.sleep],
                .ocean: [.focus],
                .fireplace: [],
                .summerNight: []
            ]
        )

        assignments.set(.rain, enabled: false, for: .sleep)
        assignments.set(.ocean, enabled: false, for: .focus)

        XCTAssertEqual(assignments.soundscapes(for: .sleep), [.rain])
        XCTAssertEqual(assignments.soundscapes(for: .focus), [.ocean])
    }
}
