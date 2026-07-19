import Foundation

enum Soundscape: String, CaseIterable, Identifiable {
    case ocean
    case fireplace
    case rain
    case summerNight

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
            return "moon.stars"
        }
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
