import XCTest
@testable import SleepAidApp

@MainActor
final class SystemIntegrationStatusTests: XCTestCase {
    func testFocusIntegrationInitialStatusIsUserFacingShortcutStatus() {
        let service = FocusIntegrationService()

        XCTAssertEqual(service.statusMessage, "快捷指令入口可用；系统专注模式自动联动暂未接入。")
    }

    func testLoginItemNotFoundStatusIsUserFacingDisabledState() {
        let message = LoginItemService.statusMessage(for: .notFound)

        XCTAssertEqual(message, "未开启。")
    }
}
