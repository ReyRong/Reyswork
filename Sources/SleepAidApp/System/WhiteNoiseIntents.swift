import AppIntents
import Foundation

struct StartSleepNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "开始助眠白噪音"
    static let description = IntentDescription("从助眠音景池随机播放一段白噪音。")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        await ShortcutRequestCenter.shared.requestStart(scene: .sleep)
        return .result(dialog: "已开始助眠白噪音")
    }
}

struct StartFocusNoiseIntent: AppIntent {
    static let title: LocalizedStringResource = "开始专注白噪音"
    static let description = IntentDescription("播放当前专注场景的白噪音。")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        await ShortcutRequestCenter.shared.requestStart(scene: .focus)
        return .result(dialog: "已开始专注白噪音")
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
    }
}
