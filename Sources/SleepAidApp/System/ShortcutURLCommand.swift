import Foundation

enum ShortcutURLCommand: String, CaseIterable, Equatable {
    case startSleep = "start-sleep"
    case startSleepRandom = "start-sleep-random"
    case togglePause = "toggle-pause"
    case stop
    case status

    init?(url: URL) {
        guard url.scheme == "whitenoise",
              url.host == "shortcut",
              let command = ShortcutURLCommand(rawValue: url.lastPathComponent) else {
            return nil
        }

        self = command
    }

    var url: URL {
        URL(string: "whitenoise://shortcut/\(rawValue)")!
    }

    var shortcutCommand: ShortcutCommand {
        switch self {
        case .startSleep:
            return .startSleep
        case .startSleepRandom:
            return .startSleepRandom
        case .togglePause:
            return .togglePause
        case .stop:
            return .stop
        case .status:
            return .queryStatus
        }
    }
}
