import Foundation

struct AppSettings: Codable, Equatable {
    var selectedScene: NoiseScene
    var selectedSoundscape: Soundscape
    var selectedMinutes: Int
    var customMinutes: Int
    var volume: Float
    var sceneAssignments: SoundscapeSceneAssignments

    static let defaults = AppSettings(
        selectedScene: .sleep,
        selectedSoundscape: .rain,
        selectedMinutes: NoiseScene.sleep.defaultMinutes,
        customMinutes: NoiseScene.sleep.defaultMinutes,
        volume: 0.55,
        sceneAssignments: .defaults
    )
}

struct AppSettingsStore {
    private let key = "WhiteNoise.AppSettings.v1"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> AppSettings {
        guard let data = userDefaults.data(forKey: key) else {
            return .defaults
        }

        do {
            return try JSONDecoder().decode(AppSettings.self, from: data).validated()
        } catch {
            return .defaults
        }
    }

    func save(_ settings: AppSettings) {
        guard let data = try? JSONEncoder().encode(settings.validated()) else {
            return
        }
        userDefaults.set(data, forKey: key)
    }
}

private extension AppSettings {
    func validated() -> AppSettings {
        var next = self
        next.selectedMinutes = min(max(selectedMinutes, 1), 480)
        next.customMinutes = min(max(customMinutes, 1), 480)
        next.volume = min(max(volume, 0), 1)

        if next.sceneAssignments.soundscapes(for: next.selectedScene).isEmpty {
            next.sceneAssignments = .defaults
        }

        if !next.sceneAssignments.soundscapes(for: next.selectedScene).contains(next.selectedSoundscape),
           let firstAvailable = next.sceneAssignments.soundscapes(for: next.selectedScene).first {
            next.selectedSoundscape = firstAvailable
        }

        return next
    }
}
