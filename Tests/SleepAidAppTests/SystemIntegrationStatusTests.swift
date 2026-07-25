import XCTest
@testable import SleepAidApp

@MainActor
final class SystemIntegrationStatusTests: XCTestCase {
    func testFocusIntegrationInitialStatusIsUserFacingShortcutStatus() {
        let service = FocusIntegrationService()

        XCTAssertEqual(service.statusMessage, "当前本机版使用快捷指令的“打开 URL”动作；原生动作待正式签名后再启用。")
    }

    func testLoginItemNotFoundStatusIsUserFacingDisabledState() {
        let message = LoginItemService.statusMessage(for: .notFound)

        XCTAssertEqual(message, "未开启。")
    }
}
