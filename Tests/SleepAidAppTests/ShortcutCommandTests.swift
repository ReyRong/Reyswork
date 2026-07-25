import XCTest
@testable import SleepAidApp

final class ShortcutCommandTests: XCTestCase {
    func testShortcutStatusSummaryIncludesSceneSoundscapeStateAndRemainingTime() {
        let snapshot = ShortcutSessionSnapshot(
            scene: .focus,
            soundscape: .library,
            playbackState: .paused,
            remainingText: "18:20",
            selectedMinutes: 45,
            volume: 0.62
        )

        XCTAssertEqual(snapshot.summary, "专注 · 图书馆氛围 · 已暂停 · 剩余 18:20 · 音量 62%")
    }

    func testShortcutDurationClampsToSupportedRange() {
        XCTAssertEqual(ShortcutCommand.setDuration(minutes: -8).clampedMinutes, 1)
        XCTAssertEqual(ShortcutCommand.setDuration(minutes: 0).clampedMinutes, 0)
        XCTAssertEqual(ShortcutCommand.setDuration(minutes: 999).clampedMinutes, 480)
        XCTAssertEqual(ShortcutCommand.setDuration(minutes: 25).clampedMinutes, 25)
    }

    func testAppShortcutsExposeAllUserActions() {
        XCTAssertEqual(WhiteNoiseShortcuts.appShortcuts.count, 8)
    }
}
