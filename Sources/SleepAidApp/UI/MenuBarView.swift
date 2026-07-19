import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var controller: SleepAidController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(controller.selectedScene.displayName, systemImage: controller.selectedScene.systemImage)
                .font(.headline)

            Text(controller.selectedSoundscape.displayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text(controller.remainingText)
                    .font(.system(.title3, design: .rounded).monospacedDigit())
                Spacer()
                playbackBadge
            }

            Divider()

            Button(playbackButtonTitle, systemImage: playbackButtonImage) {
                if controller.playbackState.isActive {
                    controller.stopSession(fadeOut: false)
                } else {
                    controller.startSelectedSession()
                }
            }

            ForEach(NoiseScene.allCases) { scene in
                Button("开始\(scene.displayName)", systemImage: scene.systemImage) {
                    controller.chooseScene(scene)
                    controller.startQuickSession(minutes: scene.defaultMinutes)
                }
            }

            Button("\(controller.selectedScene.defaultMinutes) 分钟", systemImage: "timer") {
                controller.startQuickSession(minutes: controller.selectedScene.defaultMinutes)
            }

            Divider()

            Button("打开主界面", systemImage: "macwindow") {
                openWindow(id: "main")
                NSApplication.shared.activate(ignoringOtherApps: true)
            }

            Button("退出", systemImage: "power") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(12)
        .frame(width: 240)
    }

    private var playbackBadge: some View {
        Group {
            switch controller.playbackState {
            case .idle:
                Text("待机")
            case .preparing:
                Text("准备")
            case .playing:
                Text("播放中")
            case .error:
                Text("需要音频")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var playbackButtonTitle: String {
        switch controller.playbackState {
        case .playing:
            return "停止"
        case .idle, .preparing, .error:
            return "开始"
        }
    }

    private var playbackButtonImage: String {
        switch controller.playbackState {
        case .playing:
            return "stop.fill"
        case .idle, .preparing, .error:
            return "moon.zzz.fill"
        }
    }
}
