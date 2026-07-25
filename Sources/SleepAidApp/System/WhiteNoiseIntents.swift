import AppIntents
import Foundation

enum SoundscapeShortcutOption: String, AppEnum {
    case ocean
    case fireplace
    case rain
    case summerNight
    case cafe
    case library

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "音景")
    static let caseDisplayRepresentations: [SoundscapeShortcutOption: DisplayRepresentation] = [
        .ocean: "沙滩海声",
        .fireplace: "壁炉柴火",
        .rain: "淅淅雨声",
        .summerNight: "虫鸣夏夜",
        .cafe: "咖啡厅环境",
        .library: "图书馆氛围"
    ]

    var soundscape: Soundscape {
        switch self {
        case .ocean:
            return .ocean
        case .fireplace:
            return .fireplace
        case .rain:
            return .rain
        case .summerNight:
            return .summerNight
        case .cafe:
            return .cafe
        case .library:
            return .library
        }
    }
}

struct StartSleepNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "开始助眠白噪音"
    static let description = IntentDescription("从助眠音景池随机播放一段白噪音。")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        let response = await ShortcutRequestCenter.shared.request(.start(scene: .sleep))
        return .result(dialog: IntentDialog(stringLiteral: response.dialog))
    }
}

struct StartFocusNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "开始专注白噪音"
    static let description = IntentDescription("播放当前专注场景的白噪音。")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        let response = await ShortcutRequestCenter.shared.request(.start(scene: .focus))
        return .result(dialog: IntentDialog(stringLiteral: response.dialog))
    }
}

struct PauseWhiteNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "暂停白噪音"
    static let description = IntentDescription("暂停当前播放的白噪音。")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        let response = await ShortcutRequestCenter.shared.request(.pause)
        return .result(dialog: IntentDialog(stringLiteral: response.dialog))
    }
}

struct ResumeWhiteNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "继续白噪音"
    static let description = IntentDescription("继续当前暂停的白噪音。")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        let response = await ShortcutRequestCenter.shared.request(.resume)
        return .result(dialog: IntentDialog(stringLiteral: response.dialog))
    }
}

struct StopWhiteNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "停止白噪音"
    static let description = IntentDescription("立即停止当前播放的白噪音。")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        let response = await ShortcutRequestCenter.shared.request(.stop)
        return .result(dialog: IntentDialog(stringLiteral: response.dialog))
    }
}

struct SetWhiteNoiseDurationIntent: AppIntent {
    static let title: LocalizedStringResource = "设置白噪音时长"
    static let description = IntentDescription("设置当前白噪音时长，0 表示不限时，范围为 0 到 480 分钟。")
    static let openAppWhenRun = true

    @Parameter(title: "分钟", default: 45)
    var minutes: Int

    func perform() async throws -> some IntentResult {
        let response = await ShortcutRequestCenter.shared.request(.setDuration(minutes: minutes))
        return .result(dialog: IntentDialog(stringLiteral: response.dialog))
    }
}

struct SwitchWhiteNoiseSoundscapeIntent: AppIntent {
    static let title: LocalizedStringResource = "切换白噪音音景"
    static let description = IntentDescription("切换到指定白噪音音景。")
    static let openAppWhenRun = true

    @Parameter(title: "音景")
    var soundscape: SoundscapeShortcutOption

    func perform() async throws -> some IntentResult {
        let response = await ShortcutRequestCenter.shared.request(.switchSoundscape(soundscape.soundscape))
        return .result(dialog: IntentDialog(stringLiteral: response.dialog))
    }
}

struct QueryWhiteNoiseStatusIntent: AppIntent {
    static let title: LocalizedStringResource = "查询白噪音状态"
    static let description = IntentDescription("返回当前场景、音景、播放状态、剩余时间和音量。")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        let response = await ShortcutRequestCenter.shared.request(.queryStatus)
        return .result(dialog: IntentDialog(stringLiteral: response.dialog))
    }
}

struct WhiteNoiseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartSleepNoiseIntent(),
            phrases: [
                "开始\(.applicationName)助眠",
                "播放\(.applicationName)助眠白噪音"
            ],
            shortTitle: "开始助眠",
            systemImageName: "moon.zzz.fill"
        )

        AppShortcut(
            intent: StartFocusNoiseIntent(),
            phrases: [
                "开始\(.applicationName)专注",
                "播放\(.applicationName)专注白噪音"
            ],
            shortTitle: "开始专注",
            systemImageName: "target"
        )

        AppShortcut(
            intent: PauseWhiteNoiseIntent(),
            phrases: [
                "暂停\(.applicationName)",
                "暂停\(.applicationName)白噪音"
            ],
            shortTitle: "暂停",
            systemImageName: "pause.fill"
        )

        AppShortcut(
            intent: ResumeWhiteNoiseIntent(),
            phrases: [
                "继续\(.applicationName)",
                "继续\(.applicationName)白噪音"
            ],
            shortTitle: "继续",
            systemImageName: "play.fill"
        )

        AppShortcut(
            intent: StopWhiteNoiseIntent(),
            phrases: [
                "停止\(.applicationName)",
                "停止\(.applicationName)白噪音"
            ],
            shortTitle: "停止",
            systemImageName: "stop.fill"
        )

        AppShortcut(
            intent: SetWhiteNoiseDurationIntent(),
            phrases: [
                "设置\(.applicationName)时长",
                "设置\(.applicationName)白噪音时长"
            ],
            shortTitle: "设置时长",
            systemImageName: "timer"
        )

        AppShortcut(
            intent: SwitchWhiteNoiseSoundscapeIntent(),
            phrases: [
                "切换\(.applicationName)音景",
                "切换\(.applicationName)白噪音"
            ],
            shortTitle: "切换音景",
            systemImageName: "speaker.wave.2.fill"
        )

        AppShortcut(
            intent: QueryWhiteNoiseStatusIntent(),
            phrases: [
                "查询\(.applicationName)状态",
                "\(.applicationName)现在在播放什么"
            ],
            shortTitle: "查询状态",
            systemImageName: "waveform.circle"
        )
    }
}
