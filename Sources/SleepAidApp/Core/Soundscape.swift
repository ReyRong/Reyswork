import Foundation

enum NoiseScene: String, CaseIterable, Codable, Identifiable {
    case sleep
    case focus

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sleep:
            return "助眠"
        case .focus:
            return "专注"
        }
    }

    var detail: String {
        switch self {
        case .sleep:
            return "从已选择为助眠的白噪音中随机播放，降低入睡前的选择成本。"
        case .focus:
            return "播放被标记为专注的背景音，适合工作、学习和阅读。"
        }
    }

    var systemImage: String {
        switch self {
        case .sleep:
            return "moon.zzz.fill"
        case .focus:
            return "target"
        }
    }

    var defaultMinutes: Int {
        switch self {
        case .sleep:
            return 45
        case .focus:
            return 60
        }
    }
}

enum Soundscape: String, CaseIterable, Codable, Identifiable {
    case ocean
    case fireplace
    case rain
    case summerNight
    case cafe
    case library

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ocean:
            return "沙滩海声"
        case .fireplace:
            return "壁炉柴火"
        case .rain:
            return "淅淅雨声"
        case .summerNight:
            return "虫鸣夏夜"
        case .cafe:
            return "咖啡厅环境"
        case .library:
            return "图书馆氛围"
        }
    }

    var detail: String {
        switch self {
        case .ocean:
            return "缓慢海浪和远处潮汐"
        case .fireplace:
            return "低频火焰和轻微木柴声"
        case .rain:
            return "均匀细雨落在窗外"
        case .summerNight:
            return "温柔虫鸣与安静夜色"
        case .cafe:
            return "低声交谈、杯盘轻响和柔和室内底噪"
        case .library:
            return "翻页、远处脚步和安静学习氛围"
        }
    }

    var assetBaseName: String {
        switch self {
        case .ocean:
            return "ocean"
        case .fireplace:
            return "fireplace"
        case .rain:
            return "rain"
        case .summerNight:
            return "summer-night"
        case .cafe:
            return "cafe"
        case .library:
            return "library"
        }
    }

    var systemImage: String {
        switch self {
        case .ocean:
            return "water.waves"
        case .fireplace:
            return "flame"
        case .rain:
            return "cloud.rain"
        case .summerNight:
            return "moon.stars.fill"
        case .cafe:
            return "cup.and.saucer"
        case .library:
            return "books.vertical"
        }
    }
}

struct SoundscapeSceneAssignments: Codable, Equatable {
    private var mapping: [Soundscape: Set<NoiseScene>]

    static let defaults = SoundscapeSceneAssignments(
        mapping: [
            .ocean: [.sleep],
            .fireplace: [.sleep],
            .rain: [.sleep, .focus],
            .summerNight: [.sleep, .focus],
            .cafe: [.focus],
            .library: [.focus]
        ]
    )

    init(mapping: [Soundscape: Set<NoiseScene>]) {
        var completeMapping: [Soundscape: Set<NoiseScene>] = [:]
        for soundscape in Soundscape.allCases {
            completeMapping[soundscape] = mapping[soundscape, default: []]
        }
        self.mapping = completeMapping
    }

    func scenes(for soundscape: Soundscape) -> Set<NoiseScene> {
        mapping[soundscape, default: []]
    }

    func isEnabled(_ soundscape: Soundscape, for scene: NoiseScene) -> Bool {
        scenes(for: soundscape).contains(scene)
    }

    func soundscapes(for scene: NoiseScene) -> [Soundscape] {
        Soundscape.allCases.filter { isEnabled($0, for: scene) }
    }

    mutating func set(_ soundscape: Soundscape, enabled: Bool, for scene: NoiseScene) {
        var scenes = mapping[soundscape, default: []]

        if enabled {
            scenes.insert(scene)
            mapping[soundscape] = scenes
            return
        }

        guard soundscapes(for: scene).count > 1 else {
            return
        }

        scenes.remove(scene)
        mapping[soundscape] = scenes
    }
}

enum PlaybackState: Equatable {
    case idle
    case preparing
    case playing
    case paused
    case error(String)

    var isActive: Bool {
        switch self {
        case .preparing, .playing, .paused:
            return true
        case .idle, .error:
            return false
        }
    }
}
