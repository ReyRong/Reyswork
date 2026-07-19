import XCTest
@testable import SleepAidApp

final class PlaybackSessionPresentationTests: XCTestCase {
    func testTimedSessionShowsCountdownInCenterAndClockInCorner() {
        let presentation = PlaybackSessionPresentation(
            selectedMinutes: 45,
            remainingText: "42:10",
            currentTimeText: "22:30"
        )

        XCTAssertEqual(presentation.centralText, "42:10")
        XCTAssertTrue(presentation.showsCornerClock)
    }

    func testUnlimitedSessionShowsClockInCenter() {
        let presentation = PlaybackSessionPresentation(
            selectedMinutes: 0,
            remainingText: "不限时",
            currentTimeText: "22:30"
        )

        XCTAssertEqual(presentation.centralText, "22:30")
        XCTAssertFalse(presentation.showsCornerClock)
    }
}
