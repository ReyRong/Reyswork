import XCTest
@testable import SleepAidApp

final class PlaybackStateTests: XCTestCase {
    func testOnlyPreparingAndPlayingAreActivePlaybackStates() {
        XCTAssertFalse(PlaybackState.idle.isActive)
        XCTAssertTrue(PlaybackState.preparing.isActive)
        XCTAssertTrue(PlaybackState.playing.isActive)
        XCTAssertTrue(PlaybackState.paused.isActive)
        XCTAssertFalse(PlaybackState.error("missing").isActive)
    }
}
