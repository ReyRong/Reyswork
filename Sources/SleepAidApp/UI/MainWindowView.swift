import SwiftUI

struct MainWindowView: View {
    @ObservedObject var controller: SleepAidController

    var body: some View {
        NavigationSplitView {
            List(Soundscape.allCases, selection: $controller.selectedSoundscape) { soundscape in
                Label(soundscape.displayName, systemImage: soundscape.systemImage)
                    .tag(soundscape)
            }
            .navigationTitle("音景")
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    soundscapePanel
                    timerPanel
                    controlsPanel
                    systemPanel
                }
                .padding(28)
                .frame(maxWidth: 760, alignment: .leading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(controller.selectedSoundscape.displayName, systemImage: controller.selectedSoundscape.systemImage)
                .font(.system(size: 30, weight: .semibold))
            Text(controller.selectedSoundscape.detail)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var soundscapePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("音景")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(Soundscape.allCases) { soundscape in
                    Button {
                        controller.selectedSoundscape = soundscape
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: soundscape.systemImage)
                                .font(.title2)
                            Text(soundscape.displayName)
                                .font(.headline)
                            Text(soundscape.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
                        .padding(14)
                        .background(selectionBackground(for: soundscape), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var timerPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("时长")
                .font(.headline)

            Picker("时长", selection: $controller.selectedMinutes) {
                ForEach(SleepTimer.presetMinutes, id: \.self) { minutes in
                    Text("\(minutes) 分钟").tag(minutes)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            HStack {
                Stepper(value: $controller.customMinutes, in: 1...480, step: 5) {
                    Text("自定义 \(controller.customMinutes) 分钟")
                }
                Button("应用", systemImage: "checkmark.circle") {
                    controller.startCustomSession()
                }
            }

            HStack {
                Text("剩余")
                    .foregroundStyle(.secondary)
                Text(controller.remainingText)
                    .font(.system(.title2, design: .rounded).monospacedDigit())
            }
        }
    }

    private var controlsPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("控制")
                .font(.headline)

            HStack(spacing: 12) {
                Button("开始", systemImage: "moon.zzz.fill") {
                    controller.startSelectedSession()
                }
                .buttonStyle(.borderedProminent)

                Button(controller.playbackState == .paused ? "继续" : "暂停", systemImage: controller.playbackState == .paused ? "play.fill" : "pause.fill") {
                    controller.pauseOrResume()
                }
                .disabled(!controller.playbackState.isActive)

                Button("停止", systemImage: "stop.fill") {
                    controller.stopSession()
                }
                .disabled(!controller.playbackState.isActive)
            }

            HStack {
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

            if let message = controller.lastErrorMessage {
                Label(message, systemImage: "waveform.slash")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var systemPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("系统")
                .font(.headline)

            Toggle(
                isOn: Binding(
                    get: { controller.loginItemService.isEnabled },
                    set: { controller.setLoginItemEnabled($0) }
                )
            ) {
                Label("登录后启动", systemImage: "arrow.clockwise.circle")
            }
            .disabled(!controller.loginItemService.isAvailable)

            Label(controller.loginItemService.statusMessage, systemImage: "info.circle")
                .foregroundStyle(.secondary)

            HStack {
                Label(controller.focusIntegration.statusMessage, systemImage: "moon.circle")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("测试入口", systemImage: "scope") {
                    controller.activateSleepPresetFromFocus()
                }
            }
        }
    }

    private func selectionBackground(for soundscape: Soundscape) -> Color {
        controller.selectedSoundscape == soundscape
            ? Color.accentColor.opacity(0.16)
            : Color(nsColor: .controlBackgroundColor)
    }
}
