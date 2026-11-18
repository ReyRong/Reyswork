import AppKit
import XCTest
@testable import SleepAidApp

@MainActor
final class WindowCloseBehaviorTests: XCTestCase {
    func testMainWindowCloseActionHidesWindowInsteadOfClosingIt() {
        let dockVisibility = RecordingDockVisibilityController()
        let window = makeWindow()
        let delegate = HideInsteadOfCloseWindowDelegate(dockVisibility: dockVisibility, windows: { [window] })
        XCTAssertTrue(window.isVisible)

        let shouldClose = delegate.windowShouldClose(window)

        XCTAssertFalse(shouldClose)
        XCTAssertFalse(window.isVisible)
        XCTAssertEqual(dockVisibility.actions, [.hideDock])
    }

    func testClosingOneWindowKeepsDockUntilLastWindowIsHidden() {
        let dockVisibility = RecordingDockVisibilityController()
        let main = makeWindow()
        let settings = makeWindow()
        let delegate = HideInsteadOfCloseWindowDelegate(dockVisibility: dockVisibility, windows: { [main, settings] })
        XCTAssertFalse(delegate.windowShouldClose(main))
        XCTAssertTrue(settings.isVisible)
        XCTAssertTrue(dockVisibility.actions.isEmpty)
        XCTAssertFalse(delegate.windowShouldClose(settings))
        XCTAssertEqual(dockVisibility.actions, [.hideDock])
    }

    private func makeWindow() -> RecordingVisibilityWindow {
        _ = NSApplication.shared
        return RecordingVisibilityWindow(contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
                                         styleMask: .titled, backing: .buffered, defer: false)
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


final class AppLaunchPolicyTests: XCTestCase {
    func testAutomationBeforeLaunchPreventsPendingWindow() {
        var policy = AppLaunchPolicy()
        policy.receiveAutomation()
        policy.finishLaunching(isDefaultLaunch: true, openMainWindow: true)
        XCTAssertFalse(policy.takeMainWindowRequest())
    }

    func testAutomationCancelsManualLaunchPendingBeforePresenterIsReady() {
        var policy = AppLaunchPolicy()
        policy.finishLaunching(isDefaultLaunch: true, openMainWindow: true)
        policy.receiveAutomation()
        XCTAssertFalse(policy.takeMainWindowRequest())
    }

    func testURLLaunchNeverRequestsWindow() {
        var policy = AppLaunchPolicy()
        policy.finishLaunching(isDefaultLaunch: false, openMainWindow: true)
        XCTAssertFalse(policy.takeMainWindowRequest())
    }

    func testManualLaunchPreferenceAndExplicitOpen() {
        var policy = AppLaunchPolicy()
        policy.finishLaunching(isDefaultLaunch: true, openMainWindow: false)
        XCTAssertFalse(policy.takeMainWindowRequest())
        policy.requestMainWindow()
        XCTAssertTrue(policy.takeMainWindowRequest())
        XCTAssertFalse(policy.takeMainWindowRequest())
    }

    func testExplicitOpenWorksAfterAutomation() {
        var policy = AppLaunchPolicy()
        policy.receiveAutomation()
        policy.requestMainWindow()
        XCTAssertTrue(policy.takeMainWindowRequest())
    }

    func testNormalManualLaunchRequestsWindowOnce() {
        var policy = AppLaunchPolicy()
        policy.finishLaunching(isDefaultLaunch: true, openMainWindow: true)
        XCTAssertTrue(policy.takeMainWindowRequest())
        XCTAssertFalse(policy.takeMainWindowRequest())
    }
}


@MainActor
private final class RecordingVisibilityWindow: NSWindow {
    var visibleForTest = true
    override var isVisible: Bool { visibleForTest }
    override func orderOut(_ sender: Any?) { visibleForTest = false }
}
