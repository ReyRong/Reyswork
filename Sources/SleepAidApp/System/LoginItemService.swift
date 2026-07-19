import Foundation
import ServiceManagement

@MainActor
final class LoginItemService: ObservableObject {
    @Published private(set) var isEnabled = false
    @Published private(set) var statusMessage = "登录启动未开启"
    @Published private(set) var isAvailable = true

    init() {
        refreshStatus()
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            refreshStatus()
        } catch {
            isAvailable = false
            isEnabled = false
            statusMessage = "当前原型无法修改登录项：\(error.localizedDescription)"
        }
    }

    func refreshStatus() {
        switch SMAppService.mainApp.status {
        case .enabled:
            isEnabled = true
            isAvailable = true
            statusMessage = "登录后自动启动"
        case .notRegistered:
            isEnabled = false
            isAvailable = true
            statusMessage = "登录启动未开启"
        case .requiresApproval:
            isEnabled = true
            isAvailable = true
            statusMessage = "需要在系统设置中批准登录项"
        case .notFound:
            isEnabled = false
            isAvailable = false
            statusMessage = "当前运行方式不支持登录项"
        @unknown default:
            isEnabled = false
            isAvailable = false
            statusMessage = "无法读取登录项状态"
        }
    }
}
