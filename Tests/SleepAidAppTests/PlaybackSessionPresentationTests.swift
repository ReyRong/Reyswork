import CoreGraphics
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


final class PlaybackControlInteractionTests: XCTestCase {
    func testVolumeStaysExpandedUntilDragEndsOutside() {
        var state = HoverVolumeState()
        state.isHovered = true
        state.isDragging = true
        state.isHovered = false
        XCTAssertTrue(state.isExpanded)
        state.isDragging = false
        XCTAssertFalse(state.isExpanded)
    }

    func testVolumeClosesWhenKeyboardLeavesTheControlGroup() {
        var state = HoverVolumeState()
        state.isKeyboardPresented = true
        XCTAssertTrue(state.isExpanded)
        state.isKeyboardPresented = false
        XCTAssertFalse(state.isExpanded)
    }

    func testVolumeHoverRegionKeepsTheEntryInsideWhenExpanded() {
        var state = HoverVolumeState()
        let bounds = CGRect(x: 0, y: 0, width: 48, height: 260)
        let closedRegion = state.hoverRegion(in: bounds)
        XCTAssertEqual(closedRegion, CGRect(x: 0, y: 106, width: 48, height: 48))
        XCTAssertFalse(closedRegion.contains(CGPoint(x: 24, y: 20)))
        state.isHovered = true
        XCTAssertEqual(state.hoverRegion(in: bounds), bounds)
        XCTAssertTrue(state.hoverRegion(in: bounds).contains(CGPoint(x: 24, y: 130)))
        let smallBounds = CGRect(x: 0, y: 0, width: 20, height: 30)
        XCTAssertEqual(state.hoverRegion(in: smallBounds), smallBounds)
        XCTAssertTrue(state.hoverRegion(in: .infinite).isNull)
    }

    func testDurationInputRejectsFractionsAndKeepsSceneRules() {
        XCTAssertEqual(SessionDurationInput.minutes(from: "720", scene: .sleep), 720)
        XCTAssertEqual(SessionDurationInput.minutes(from: "0", scene: .focus), 0)
        for input in ["", "0", "721", "1.5", "abc", "-1"] {
            XCTAssertNil(SessionDurationInput.minutes(from: input, scene: .sleep))
        }
    }
}
