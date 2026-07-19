import Foundation

@MainActor
final class FocusIntegrationService: ObservableObject {
    @Published private(set) var statusMessage = "快捷指令入口可用；系统专注模式自动联动暂未接入。"

    private var activateSleepPresetAction: (() -> Void)?

    init(activateSleepPresetAction: (() -> Void)? = nil) {
        self.activateSleepPresetAction = activateSleepPresetAction
    }

    func configure(activateSleepPresetAction: @escaping () -> Void) {
        self.activateSleepPresetAction = activateSleepPresetAction
    }

    func activateSleepPreset() {
        activateSleepPresetAction?()
        statusMessage = "已通过快捷指令入口启动默认助眠预设。"
    }
}
