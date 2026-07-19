import SwiftUI

struct MainWindowView: View {
    @ObservedObject var controller: SleepAidController

    var body: some View {
        NavigationSplitView {
            List(NoiseScene.allCases, selection: Binding(
                get: { controller.selectedScene },
                set: { scene in
                    if let scene {
                        controller.chooseScene(scene)
                    }
                }
            )) { scene in
                VStack(alignment: .leading, spacing: 4) {
                    Label(scene.displayName, systemImage: scene.systemImage)
                    Text("\(controller.sceneAssignments.soundscapes(for: scene).count) 个音景")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .tag(scene)
            }
            .navigationTitle("场景")
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    soundscapePanel
                    timerPanel
                    controlsPanel
                    libraryPanel
                    systemPanel
                }
                .padding(28)
                .frame(maxWidth: 780, alignment: .leading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(controller.selectedScene.displayName, systemImage: controller.selectedScene.systemImage)
                .font(.system(size: 30, weight: .semibold))
            Text(controller.selectedScene.detail)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var soundscapePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("当前场景的白噪音")
                    .font(.headline)
                Spacer()
                Text("\(controller.availableSoundscapes.count) 个可用")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(controller.availableSoundscapes) { soundscape in
                    Button {
                        controller.chooseSoundscape(soundscape)
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

            if controller.selectedScene == .sleep {
                Label("开始助眠时会从这些白噪音里随机选择一个。", systemImage: "shuffle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var timerPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("时长")

            Picker("时长", selection: $controller.selectedMinutes) {
                if controller.selectedScene == .focus {
                    Text("不限时").tag(0)
                }
                ForEach(SleepTimer.presetMinutes, id: \.self) { minutes in
                    Text("\(minutes) 分钟").tag(minutes)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            HStack {
                if controller.selectedScene == .focus {
                    Toggle(
                        "不限时",
                        isOn: Binding(
                            get: { controller.selectedMinutes == 0 },
                            set: { controller.setUnlimitedFocusEnabled($0) }
                        )
                    )
                    .toggleStyle(.checkbox)
                }

                Stepper(value: $controller.customMinutes, in: 1...480, step: 5) {
                    Text("自定义 \(controller.customMinutes) 分钟")
                }
                .disabled(controller.selectedScene == .focus && controller.selectedMinutes == 0)

                Button("应用", systemImage: "checkmark.circle") {
                    controller.startCustomSession()
                }
                .disabled(controller.selectedScene == .focus && controller.selectedMinutes == 0)
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
            sectionHeader("播放")

            HStack(spacing: 12) {
                Button(primaryPlaybackTitle, systemImage: primaryPlaybackImage) {
                    if controller.playbackState.isActive {
                        controller.stopSession(fadeOut: false)
                    } else {
                        controller.startSelectedSession()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button(pauseResumeTitle, systemImage: pauseResumeImage) {
                    if controller.playbackState == .paused {
                        controller.resumeSession()
                    } else {
                        controller.pauseSession()
                    }
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

    private var libraryPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                sectionHeader("媒体库用途")
                Text("勾选每个白噪音适合的场景。每个场景至少会保留一个可用音景。")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(Soundscape.allCases) { soundscape in
                    HStack(spacing: 14) {
                        Label(soundscape.displayName, systemImage: soundscape.systemImage)
                            .frame(width: 150, alignment: .leading)

                        ForEach(NoiseScene.allCases) { scene in
                            Toggle(
                                scene.displayName,
                                isOn: Binding(
                                    get: {
                                        controller.sceneAssignments.isEnabled(soundscape, for: scene)
                                    },
                                    set: { enabled in
                                        controller.setSceneAssignment(soundscape, enabled: enabled, for: scene)
                                    }
                                )
                            )
                            .toggleStyle(.checkbox)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private var systemPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("系统")

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
                Button("测试助眠入口", systemImage: "scope") {
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

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }

    private var primaryPlaybackTitle: String {
        controller.playbackState.isActive ? "停止" : "开始\(controller.selectedScene.displayName)"
    }

    private var primaryPlaybackImage: String {
        controller.playbackState.isActive ? "stop.fill" : controller.selectedScene.systemImage
    }

    private var pauseResumeTitle: String {
        controller.playbackState == .paused ? "继续" : "暂停"
    }

    private var pauseResumeImage: String {
        controller.playbackState == .paused ? "play.fill" : "pause.fill"
    }
}
