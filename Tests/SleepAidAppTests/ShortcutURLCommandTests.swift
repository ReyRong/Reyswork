import XCTest
@testable import SleepAidApp

final class ShortcutURLCommandTests: XCTestCase {
    func testParsesSupportedShortcutURLs() {
        XCTAssertEqual(
            ShortcutURLCommand(url: URL(string: "whitenoise://shortcut/start-sleep")!),
            .startSleep
        )
        XCTAssertEqual(
            ShortcutURLCommand(url: URL(string: "whitenoise://shortcut/start-sleep-random")!),
            .startSleepRandom
        )
        XCTAssertEqual(
            ShortcutURLCommand(url: URL(string: "whitenoise://shortcut/toggle-pause")!),
            .togglePause
        )
        XCTAssertEqual(
            ShortcutURLCommand(url: URL(string: "whitenoise://shortcut/stop")!),
            .stop
        )
        XCTAssertEqual(
            ShortcutURLCommand(url: URL(string: "whitenoise://shortcut/status")!),
            .status
        )
    }

    func testRejectsUnsupportedShortcutURLs() {
        XCTAssertNil(ShortcutURLCommand(url: URL(string: "https://shortcut/start-sleep")!))
        XCTAssertNil(ShortcutURLCommand(url: URL(string: "whitenoise://settings")!))
        XCTAssertNil(ShortcutURLCommand(url: URL(string: "whitenoise://shortcut/start-focus")!))
    }

    func testShortcutURLsAreStable() {
        XCTAssertEqual(ShortcutURLCommand.startSleep.url.absoluteString, "whitenoise://shortcut/start-sleep")
        XCTAssertEqual(ShortcutURLCommand.startSleepRandom.url.absoluteString, "whitenoise://shortcut/start-sleep-random")
        XCTAssertEqual(ShortcutURLCommand.togglePause.url.absoluteString, "whitenoise://shortcut/toggle-pause")
        XCTAssertEqual(ShortcutURLCommand.stop.url.absoluteString, "whitenoise://shortcut/stop")
        XCTAssertEqual(ShortcutURLCommand.status.url.absoluteString, "whitenoise://shortcut/status")
    }
}
