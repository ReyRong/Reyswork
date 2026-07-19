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
                controller.pauseOrResume()
            }

            Button("\(controller.selectedScene.defaultMinutes) 分钟", systemImage: "timer") {
                controller.startQuickSession(minutes: controller.selectedScene.defaultMinutes)
            }

            Button("停止", systemImage: "stop.fill") {
                controller.stopSession()
            }
            .disabled(!controller.playbackState.isActive)

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
            case .paused:
                Text("暂停")
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
            return "暂停"
        case .paused:
            return "继续"
        case .idle, .preparing, .error:
            return "开始"
        }
    }

    private var playbackButtonImage: String {
        switch controller.playbackState {
        case .playing:
            return "pause.fill"
        case .paused:
            return "play.fill"
        case .idle, .preparing, .error:
            return "moon.zzz.fill"
        }
    }
}
