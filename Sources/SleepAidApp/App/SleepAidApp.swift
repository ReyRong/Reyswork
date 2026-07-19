import SwiftUI

@main
struct SleepAidApp: App {
    @StateObject private var controller = SleepAidController()

    var body: some Scene {
        Window("白噪音", id: "main") {
            MainWindowView(controller: controller)
                .frame(minWidth: 720, minHeight: 500)
                .hideInsteadOfCloseWindow()
        }
        .windowResizability(.contentMinSize)

        MenuBarExtra("白噪音", systemImage: controller.menuBarSymbol) {
            MenuBarView(controller: controller)
        }
        .menuBarExtraStyle(.window)
    }
}
