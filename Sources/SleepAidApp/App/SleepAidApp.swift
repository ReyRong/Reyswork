import SwiftUI

@main
struct SleepAidApp: App {
    @StateObject private var controller = SleepAidController()

    var body: some Scene {
        Window("白噪音", id: "main") {
            MainWindowView(controller: controller)
                .frame(minWidth: 1040, minHeight: 720)
                .hideInsteadOfCloseWindow()
        }
        .windowResizability(.contentMinSize)

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
}
