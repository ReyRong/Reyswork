import Foundation

@MainActor
final class FocusIntegrationService: ObservableObject {
    @Published private(set) var statusMessage = "当前本机版使用快捷指令的“打开 URL”动作；原生动作待正式签名后再启用。"

    private var activateSleepPresetAction: (() -> Void)?

    init(activateSleepPresetAction: (() -> Void)? = nil) {
        self.activateSleepPresetAction = activateSleepPresetAction
    }

    func configure(activateSleepPresetAction: @escaping () -> Void) {
        self.activateSleepPresetAction = activateSleepPresetAction
    }

    func activateSleepPreset() {
        activateSleepPresetAction?()
        statusMessage = "已通过 URL 入口启动默认助眠预设。"
    }
}
