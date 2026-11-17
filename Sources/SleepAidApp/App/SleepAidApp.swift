import AppKit
import SwiftUI

@main
struct SleepAidApp: App {
    @NSApplicationDelegateAdaptor(ShortcutApplicationDelegate.self) private var appDelegate
    @StateObject private var controller = SleepAidController()

    var body: some Scene {
        Window("白噪音", id: "main") {
            MainWindowView(controller: controller)
                .onAppear {
                    appDelegate.configure(controller: controller)
                }
                .frame(minWidth: 900, minHeight: 680)
                .setInitialWindowContentSize(width: 1060, height: 740)
                .restoreWindowContentSize(width: 1060, height: 740, when: !controller.playbackState.isActive)
                .hideInsteadOfCloseWindow()
        }
        .defaultSize(width: 1060, height: 740)
        .windowResizability(.contentMinSize)
        .commands {
            playbackCommands
        }

        Window("设置", id: "settings") {
            SettingsWindowView(controller: controller)
                .frame(minWidth: 480, minHeight: 540)
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

@MainActor
final class ShortcutApplicationDelegate: NSObject, NSApplicationDelegate {
    private weak var controller: SleepAidController?
    private var pendingURLs: [URL] = []

    func configure(controller: SleepAidController) {
        self.controller = controller
        pendingURLs.forEach(dispatch)
        pendingURLs.removeAll()
    }

    nonisolated func application(_ application: NSApplication, open urls: [URL]) {
        Task { @MainActor in
            urls.forEach(dispatch)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        controller?.prepareForTermination()
    }

    private func dispatch(_ url: URL) {
        guard let controller else {
            pendingURLs.append(url)
            return
        }

        _ = controller.handleShortcutURL(url)
    }
}
