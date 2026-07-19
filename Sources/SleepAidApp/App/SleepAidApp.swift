import SwiftUI

@main
struct SleepAidApp: App {
    @StateObject private var controller = SleepAidController()

    var body: some Scene {
        WindowGroup("白噪音", id: "main") {
            MainWindowView(controller: controller)
                .frame(minWidth: 720, minHeight: 500)
        }
        .windowResizability(.contentMinSize)

        MenuBarExtra("白噪音", systemImage: controller.menuBarSymbol) {
            MenuBarView(controller: controller)
        }
    }
}
