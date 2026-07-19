import SwiftUI

@main
struct SleepAidApp: App {
    @StateObject private var controller = SleepAidController()

    var body: some Scene {
        Window("白噪音", id: "main") {
            MainWindowView(controller: controller)
                .frame(minWidth: 860, minHeight: 580)
                .setInitialWindowContentSize(width: 980, height: 580)
                .hideInsteadOfCloseWindow()
        }
        .defaultSize(width: 980, height: 580)
        .windowResizability(.contentMinSize)
        .commands {
            playbackCommands
        }

        Window("设置", id: "settings") {
            SettingsWindowView(controller: controller)
                .frame(minWidth: 560, minHeight: 560)
        }
        .windowResizability(.contentMinSize)

        MenuBarExtra("白噪音", systemImage: controller.menuBarSymbol) {
            MenuBarView(controller: controller)
        }
        .menuBarExtraStyle(.window)
    }

    @CommandsBuilder
    private var playbackCommands: some Commands {
        CommandMenu("播放") {
            Button("开始") {
                controller.startSelectedSession()
            }
            .keyboardShortcut(.return, modifiers: [.command])
            .disabled(controller.playbackState.isActive)

            Button(controller.playbackState == .paused ? "继续" : "暂停") {
                if controller.playbackState == .paused {
                    controller.resumeSession()
                } else {
                    controller.pauseSession()
                }
            }
            .keyboardShortcut("p", modifiers: [.command])
            .disabled(!controller.playbackState.isActive)

            Button("停止") {
                controller.stopSession(fadeOut: false)
            }
            .keyboardShortcut(".", modifiers: [.command])
            .disabled(!controller.playbackState.isActive)
        }
    }
}
