import SwiftUI

@main
struct SleepAidApp: App {
    @StateObject private var controller = SleepAidController()

    var body: some Scene {
        MenuBarExtra("助眠", systemImage: controller.menuBarSymbol) {
            MenuBarView(controller: controller)
        }

        WindowGroup("助眠", id: "main") {
            MainWindowView(controller: controller)
                .frame(minWidth: 720, minHeight: 500)
        }
        .windowResizability(.contentMinSize)
    }
}
