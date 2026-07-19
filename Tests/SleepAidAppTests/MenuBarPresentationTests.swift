import XCTest
@testable import SleepAidApp

final class MenuBarPresentationTests: XCTestCase {
    func testIdleMenuBarPresentationUsesNeutralWaveformSymbol() {
        let presentation = MenuBarPresentation(
            scene: .focus,
            soundscape: .cafe,
            playbackState: .idle,
            remainingText: "--:--"
        )

        XCTAssertEqual(presentation.symbolName, "waveform.circle")
        XCTAssertEqual(presentation.title, "专注 · 咖啡厅环境")
        XCTAssertEqual(presentation.subtitle, "待机 · --:--")
    }

    func testPlayingMenuBarPresentationUsesFilledWaveformSymbol() {
        let presentation = MenuBarPresentation(
            scene: .sleep,
            soundscape: .rain,
            playbackState: .playing,
            remainingText: "18:32"
        )

        XCTAssertEqual(presentation.symbolName, "waveform.circle.fill")
        XCTAssertEqual(presentation.title, "助眠 · 淅淅雨声")
        XCTAssertEqual(presentation.subtitle, "播放中 · 18:32")
    }
}
