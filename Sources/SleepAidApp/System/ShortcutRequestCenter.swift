import Foundation

@MainActor
final class ShortcutRequestCenter {
    static let shared = ShortcutRequestCenter()

    private var handler: ((NoiseScene) -> Void)?

    private init() {}

    func configure(handler: @escaping (NoiseScene) -> Void) {
        self.handler = handler
    }

    func requestStart(scene: NoiseScene) {
        handler?(scene)
    }
}
