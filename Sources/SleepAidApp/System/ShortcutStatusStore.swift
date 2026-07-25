import Foundation

struct ShortcutStatusStore {
    private let key = "WhiteNoise.ShortcutStatus.v1"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> String {
        userDefaults.string(forKey: key) ?? PlaybackState.idle.shortcutDisplayName
    }

    func save(_ status: String) {
        userDefaults.set(status, forKey: key)
    }
}
