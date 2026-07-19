import XCTest
@testable import SleepAidApp

@MainActor
final class SleepTimerTests: XCTestCase {
    func testStartSetsRunningStateAndRemainingTime() {
        let timer = SleepTimer()

        timer.start(duration: 60) {}

        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(timer.durationSeconds, 60, accuracy: 0.01)
        XCTAssertGreaterThan(timer.remainingSeconds, 0)
        XCTAssertLessThanOrEqual(timer.remainingSeconds, 60)

        timer.cancel()
    }

    func testFocusDefaultDurationIsUnlimited() {
        XCTAssertEqual(NoiseScene.focus.defaultMinutes, 0)
    }

    func testCancelClearsTimerState() {
        let timer = SleepTimer()

        timer.start(duration: 60) {}
        timer.cancel()

        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.durationSeconds, 0, accuracy: 0.01)
        XCTAssertEqual(timer.remainingSeconds, 0, accuracy: 0.01)
    }

    func testPauseAndResumePreservesRemainingTime() async {
        let timer = SleepTimer()

        timer.start(duration: 20) {}
        try? await Task.sleep(nanoseconds: 200_000_000)
        timer.pause()
        let pausedRemaining = timer.remainingSeconds
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertFalse(timer.isRunning)
        XCTAssertTrue(timer.isPaused)
        XCTAssertEqual(timer.remainingSeconds, pausedRemaining, accuracy: 0.05)

        timer.resume()

        XCTAssertTrue(timer.isRunning)
        XCTAssertFalse(timer.isPaused)

        timer.cancel()
    }

    func testFormattedRemainingStaysVisibleWhilePaused() async {
        let timer = SleepTimer()

        timer.start(duration: 20) {}
        try? await Task.sleep(nanoseconds: 200_000_000)
        timer.pause()
        let pausedText = timer.formattedRemaining()
        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertTrue(timer.isPaused)
        XCTAssertEqual(timer.formattedRemaining(), pausedText)

        timer.cancel()
    }

    func testCompletionFiresAndStopsTimer() async {
        let timer = SleepTimer()
        let expectation = expectation(description: "timer completes")

        timer.start(duration: 1) {
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.6)

        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.remainingSeconds, 0, accuracy: 0.01)
    }

    func testFormattedRemainingUsesMinuteSecondDisplay() {
        let timer = SleepTimer()

        timer.start(duration: 65) {}

        XCTAssertTrue(["01:04", "01:05"].contains(timer.formattedRemaining()))

        timer.cancel()
    }
}
