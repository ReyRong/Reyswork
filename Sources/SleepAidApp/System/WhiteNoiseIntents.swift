import AppIntents
import AppKit
import Foundation

struct StartSleepNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "开始助眠白噪音"
    static let description = IntentDescription("使用当前助眠音景开始播放白噪音。")
    static let openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        await ShortcutURLRunner.open(.startSleep)
        return .result(dialog: "已开始助眠白噪音")
    }
}

struct StartRandomSleepNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "助眠白噪音随机"
    static let description = IntentDescription("从已选择为助眠的白噪音中随机播放。")
    static let openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        await ShortcutURLRunner.open(.startSleepRandom)
        return .result(dialog: "已随机播放助眠白噪音")
    }
}

struct ToggleWhiteNoisePauseIntent: AppIntent {
    static let title: LocalizedStringResource = "暂停或继续白噪音"
    static let description = IntentDescription("播放时暂停，暂停时继续，未播放时不自动开始。")
    static let openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        await ShortcutURLRunner.open(.togglePause)
        return .result(dialog: "已发送暂停或继续指令")
    }
}

struct StopWhiteNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "停止白噪音"
    static let description = IntentDescription("立即停止当前播放的白噪音。")
    static let openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        await ShortcutURLRunner.open(.stop)
        return .result(dialog: "已停止白噪音")
    }
}

struct QueryWhiteNoiseStatusIntent: AppIntent {
    static let title: LocalizedStringResource = "查询白噪音状态"
    static let description = IntentDescription("返回白噪音当前是否正在播放、已暂停或未播放。")
    static let openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        let status = ShortcutStatusStore().load()
        return .result(dialog: IntentDialog(stringLiteral: status))
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
            intent: StartRandomSleepNoiseIntent(),
            phrases: [
                "随机播放\(.applicationName)助眠",
                "随机\(.applicationName)助眠白噪音"
            ],
            shortTitle: "助眠随机",
            systemImageName: "shuffle"
        )

        AppShortcut(
            intent: ToggleWhiteNoisePauseIntent(),
            phrases: [
                "暂停或继续\(.applicationName)",
                "切换\(.applicationName)播放状态"
            ],
            shortTitle: "暂停或继续",
            systemImageName: "playpause.fill"
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
            intent: QueryWhiteNoiseStatusIntent(),
            phrases: [
                "查询\(.applicationName)状态",
                "\(.applicationName)现在在播放吗"
            ],
            shortTitle: "查询状态",
            systemImageName: "waveform.circle"
        )
    }
}

private enum ShortcutURLRunner {
    static func open(_ command: ShortcutURLCommand) async {
        _ = await MainActor.run {
            NSWorkspace.shared.open(command.url)
        }
    }
}
