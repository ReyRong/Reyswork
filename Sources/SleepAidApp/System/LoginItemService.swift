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
            statusMessage = "无法修改登录项。请确认应用已安装在“应用程序”文件夹后重试。"
        }
    }

    func refreshStatus() {
        switch SMAppService.mainApp.status {
        case .enabled:
            isEnabled = true
            isAvailable = true
            statusMessage = Self.statusMessage(for: .enabled)
        case .notRegistered:
            isEnabled = false
            isAvailable = true
            statusMessage = Self.statusMessage(for: .notRegistered)
        case .requiresApproval:
            isEnabled = true
            isAvailable = true
            statusMessage = Self.statusMessage(for: .requiresApproval)
        case .notFound:
            isEnabled = false
            isAvailable = true
            statusMessage = Self.statusMessage(for: .notFound)
        @unknown default:
            isEnabled = false
            isAvailable = false
            statusMessage = Self.statusMessage(for: .unknown)
        }
    }

    static func statusMessage(for status: LoginItemStatus) -> String {
        switch status {
        case .enabled:
            return "已开启，登录后会自动启动。"
        case .notRegistered:
            return "未开启。"
        case .requiresApproval:
            return "已请求开启，请在系统设置的登录项中批准。"
        case .notFound:
            return "未开启。"
        case .unknown:
            return "无法读取登录项状态。"
        }
    }
}

enum LoginItemStatus {
    case enabled
    case notRegistered
    case requiresApproval
    case notFound
    case unknown
}
