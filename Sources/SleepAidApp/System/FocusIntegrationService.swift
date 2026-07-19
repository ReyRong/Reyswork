import Foundation

@MainActor
final class FocusIntegrationService: ObservableObject {
    @Published private(set) var statusMessage = "已预留专注模式入口，后续可接入 Focus Filter 或 App Intent。"

    private var activateSleepPresetAction: (() -> Void)?

    init(activateSleepPresetAction: (() -> Void)? = nil) {
        self.activateSleepPresetAction = activateSleepPresetAction
    }

    func configure(activateSleepPresetAction: @escaping () -> Void) {
        self.activateSleepPresetAction = activateSleepPresetAction
    }

    func activateSleepPreset() {
        activateSleepPresetAction?()
        statusMessage = "已通过 Focus 入口启动默认助眠预设。"
    }
}
