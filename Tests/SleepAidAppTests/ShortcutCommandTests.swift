import XCTest
@testable import SleepAidApp

final class ShortcutCommandTests: XCTestCase {
    func testShortcutStatusSummaryUsesMinimalPlaybackState() {
        let snapshot = ShortcutSessionSnapshot(
            scene: .focus,
            soundscape: .library,
            playbackState: .paused,
            remainingText: "18:20",
            selectedMinutes: 45,
            volume: 0.62
        )

        XCTAssertEqual(snapshot.summary, "已暂停")
    }

    func testShortcutStatusSummaryDistinguishesIdlePlayingAndPaused() {
        XCTAssertEqual(shortcutSummary(for: .idle), "未播放")
        XCTAssertEqual(shortcutSummary(for: .preparing), "正在播放")
        XCTAssertEqual(shortcutSummary(for: .playing), "正在播放")
        XCTAssertEqual(shortcutSummary(for: .paused), "已暂停")
    }

    func testAppShortcutsExposeV1UserActions() {
        XCTAssertEqual(WhiteNoiseShortcuts.appShortcuts.count, 5)
    }

    private func shortcutSummary(for playbackState: PlaybackState) -> String {
        ShortcutSessionSnapshot(
            scene: .sleep,
            soundscape: .rain,
            playbackState: playbackState,
            remainingText: "--:--",
            selectedMinutes: 45,
            volume: 0.55
        ).summary
    }
}
