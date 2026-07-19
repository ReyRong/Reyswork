import AppKit
import XCTest
@testable import SleepAidApp

@MainActor
final class WindowCloseBehaviorTests: XCTestCase {
    func testMainWindowCloseActionHidesWindowInsteadOfClosingIt() {
        let delegate = HideInsteadOfCloseWindowDelegate()
        let window = NSWindow()

        window.makeKeyAndOrderFront(nil)
        XCTAssertTrue(window.isVisible)

        let shouldClose = delegate.windowShouldClose(window)

        XCTAssertFalse(shouldClose)
        XCTAssertFalse(window.isVisible)
    }
}
