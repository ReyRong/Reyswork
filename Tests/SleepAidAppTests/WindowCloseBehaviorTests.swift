import AppKit
import XCTest
@testable import SleepAidApp

@MainActor
final class WindowCloseBehaviorTests: XCTestCase {
    func testMainWindowCloseActionHidesWindowInsteadOfClosingIt() {
        let dockVisibility = RecordingDockVisibilityController()
        let delegate = HideInsteadOfCloseWindowDelegate(dockVisibility: dockVisibility)
        let window = NSWindow()

        window.makeKeyAndOrderFront(nil)
        XCTAssertTrue(window.isVisible)

        let shouldClose = delegate.windowShouldClose(window)

        XCTAssertFalse(shouldClose)
        XCTAssertFalse(window.isVisible)
        XCTAssertEqual(dockVisibility.actions, [.hideDock])
    }

    func testOpeningMainWindowShowsDockAgain() {
        let dockVisibility = RecordingDockVisibilityController()

        MainWindowDockPresenter.showDock(dockVisibility: dockVisibility)

        XCTAssertEqual(dockVisibility.actions, [.showDock])
    }
}

private final class RecordingDockVisibilityController: DockVisibilityControlling {
    enum Action: Equatable {
        case hideDock
        case showDock
    }

    private(set) var actions: [Action] = []

    func hideDockIcon() {
        actions.append(.hideDock)
    }

    func showDockIcon() {
        actions.append(.showDock)
    }
}
