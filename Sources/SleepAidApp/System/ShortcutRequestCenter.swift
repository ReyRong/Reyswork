import Foundation

@MainActor
final class ShortcutRequestCenter {
    static let shared = ShortcutRequestCenter()

    private var handler: ((ShortcutCommand) -> ShortcutCommandResponse)?

    private init() {}

    func configure(handler: @escaping (ShortcutCommand) -> ShortcutCommandResponse) {
        self.handler = handler
    }

    func request(_ command: ShortcutCommand) -> ShortcutCommandResponse {
        if let response = handler?(command) {
            return response
        }

        return ShortcutCommandResponse(
            dialog: "白噪音还没有准备好，请先打开应用。",
            snapshot: ShortcutSessionSnapshot(
                scene: .sleep,
                soundscape: .rain,
                playbackState: .idle,
                remainingText: "--:--",
                selectedMinutes: NoiseScene.sleep.defaultMinutes,
                volume: 0.55
            )
        )
    }
}
