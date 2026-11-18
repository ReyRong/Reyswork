import AppKit
import SwiftUI

@main
struct SleepAidApp: App {
    @NSApplicationDelegateAdaptor(ShortcutApplicationDelegate.self) private var appDelegate
    @StateObject private var controller = SleepAidController()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        // 自动化冷启动不创建主窗口，命令接入不能依赖窗口出现。
        let _ = appDelegate.configure(controller: controller) { [openWindow] id in openWindow(id: id) }

        MenuBarExtra("白噪音", systemImage: controller.menuBarSymbol) {
            MenuBarView(controller: controller)
        }
        .menuBarExtraStyle(.window)

        Window("白噪音", id: "main") {
            MainWindowView(controller: controller)
                .frame(minWidth: 1000, minHeight: 680)
                .setInitialWindowContentSize(width: 1060, height: 740)
                .restoreWindowContentSize(width: 1060, height: 740, when: !controller.playbackState.isActive)
                .hideInsteadOfCloseWindow()
                .handlesExternalEvents(preferring: [], allowing: [])
        }
        .defaultSize(width: 1060, height: 740)
        .windowResizability(.contentMinSize)
        .opensOnlyWhenRequested()
        .commands {
            playbackCommands
        }

        Window("设置", id: "settings") {
            SettingsWindowView(controller: controller)
                .frame(minWidth: 480, minHeight: 540)
                .hideInsteadOfCloseWindow()
                .handlesExternalEvents(preferring: [], allowing: [])
        }
        .windowResizability(.contentMinSize)
        .opensOnlyWhenRequested()
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

struct AppLaunchPolicy {
    private(set) var receivedAutomation = false
    private(set) var hasPendingMainWindowRequest = false

    mutating func receiveAutomation() {
        receivedAutomation = true
        hasPendingMainWindowRequest = false
    }

    mutating func finishLaunching(isDefaultLaunch: Bool, openMainWindow: Bool) {
        hasPendingMainWindowRequest = isDefaultLaunch && openMainWindow && !receivedAutomation
    }

    mutating func requestMainWindow() { hasPendingMainWindowRequest = true }

    mutating func takeMainWindowRequest() -> Bool {
        defer { hasPendingMainWindowRequest = false }
        return hasPendingMainWindowRequest
    }
}

@MainActor
final class ShortcutApplicationDelegate: NSObject, NSApplicationDelegate {
    private weak var controller: SleepAidController?
    private var pendingURLs: [URL] = []
    private var openWindow: ((String) -> Void)?
    private var launchPolicy = AppLaunchPolicy()

    func configure(controller: SleepAidController, openWindow: @escaping (String) -> Void) {
        let controllerChanged = self.controller !== controller
        self.controller = controller
        self.openWindow = openWindow
        guard controllerChanged || launchPolicy.hasPendingMainWindowRequest else { return }
        let urls = pendingURLs
        pendingURLs.removeAll()
        Task { @MainActor [weak self] in
            urls.forEach { self?.dispatch($0) }
            self?.presentPendingMainWindow()
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let isDefaultLaunch = notification.userInfo?[NSApplication.launchIsDefaultUserInfoKey] as? Bool ?? false
        let opensMain = UserDefaults.standard.object(forKey: "settings.openMainWindowOnLaunch") as? Bool ?? true
        launchPolicy.finishLaunching(isDefaultLaunch: isDefaultLaunch, openMainWindow: opensMain)
        presentPendingMainWindow()
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool { false }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        guard !hasVisibleWindows else { return true }
        launchPolicy.requestMainWindow()
        presentPendingMainWindow()
        return false
    }

    nonisolated func application(_ application: NSApplication, open urls: [URL]) {
        Task { @MainActor in urls.forEach(dispatch) }
    }

    func applicationWillTerminate(_ notification: Notification) {
        controller?.prepareForTermination()
    }

    private func presentPendingMainWindow() {
        guard let openWindow, launchPolicy.takeMainWindowRequest() else { return }
        openWindow("main")
        MainWindowDockPresenter.showDock()
    }

    private func dispatch(_ url: URL) {
        guard ShortcutURLCommand(url: url) != nil else { return }
        launchPolicy.receiveAutomation()
        guard let controller else {
            pendingURLs.append(url)
            return
        }
        _ = controller.handleShortcutURL(url)
    }
}
