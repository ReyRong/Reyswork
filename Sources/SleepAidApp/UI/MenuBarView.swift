import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var controller: SleepAidController
    @Environment(\.openWindow) private var openWindow

    private let quickMinutes = [20, 45, 90]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(controller.menuBarPresentation.title, systemImage: controller.selectedScene.systemImage)
                .font(.headline)

            Text(controller.menuBarPresentation.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            volumeControl

            Divider()

            Button("开始\(controller.selectedScene.displayName)", systemImage: controller.selectedScene.systemImage) {
                controller.startSelectedSession()
            }

            Button(pauseResumeTitle, systemImage: pauseResumeImage) {
                if controller.playbackState == .paused {
                    controller.resumeSession()
                } else {
                    controller.pauseSession()
                }
            }
            .disabled(!controller.playbackState.isActive)

            Button("停止", systemImage: "stop.fill") {
                controller.stopSession(fadeOut: false)
            }
            .disabled(!controller.playbackState.isActive)

            Divider()

            ForEach(NoiseScene.allCases) { scene in
                Button("开始\(scene.displayName)", systemImage: scene.systemImage) {
                    controller.chooseScene(scene)
                    controller.startQuickSession(minutes: scene.defaultMinutes)
                }
            }

            Divider()

            Text("切换音景")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(controller.availableSoundscapes) { soundscape in
                Button(soundscapeMenuTitle(for: soundscape), systemImage: soundscape.systemImage) {
                    controller.chooseSoundscape(soundscape)
                }
            }

            Divider()

            Text("时长")
                .font(.caption)
                .foregroundStyle(.secondary)

            if controller.selectedScene == .focus {
                Button("不限时", systemImage: controller.selectedMinutes == 0 ? "checkmark.circle.fill" : "infinity") {
                    controller.startQuickSession(minutes: 0)
                }
            }

            ForEach(quickMinutes, id: \.self) { minutes in
                Button(durationMenuTitle(for: minutes), systemImage: controller.selectedMinutes == minutes ? "checkmark.circle.fill" : "timer") {
                    controller.startQuickSession(minutes: minutes)
                }
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
        .frame(width: 260)
    }

    private var volumeControl: some View {
        HStack(spacing: 8) {
            Image(systemName: "speaker.wave.2")
            Slider(
                value: Binding(
                    get: { Double(controller.volume) },
                    set: { controller.volume = Float($0) }
                ),
                in: 0...1
            )
            Text("\(Int(controller.volume * 100))%")
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 42, alignment: .trailing)
        }
    }

    private func soundscapeMenuTitle(for soundscape: Soundscape) -> String {
        controller.selectedSoundscape == soundscape
            ? "\(soundscape.displayName) ✓"
            : soundscape.displayName
    }

    private func durationMenuTitle(for minutes: Int) -> String {
        controller.selectedMinutes == minutes
            ? "\(minutes) 分钟 ✓"
            : "\(minutes) 分钟"
    }

    private var pauseResumeTitle: String {
        controller.playbackState == .paused ? "继续" : "暂停"
    }

    private var pauseResumeImage: String {
        controller.playbackState == .paused ? "play.fill" : "pause.fill"
    }
}
