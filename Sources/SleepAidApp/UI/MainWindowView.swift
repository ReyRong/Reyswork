import SwiftUI

struct MainWindowView: View {
    @ObservedObject var controller: SleepAidController
    @Environment(\.colorScheme) private var colorScheme
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    private let soundscapeColumns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sceneSidebar
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    nowPlayingPanel
                    soundscapePanel
                    libraryPanel
                    footerBar
                }
                .padding(24)
                .frame(maxWidth: 980, alignment: .leading)
            }
            .background(AppTheme.windowBackground)
        }
    }

    private var sceneSidebar: some View {
        List(NoiseScene.allCases, selection: Binding(
            get: { controller.selectedScene },
            set: { scene in
                if let scene {
                    controller.chooseScene(scene)
                }
            }
        )) { scene in
            Label {
                VStack(alignment: .leading, spacing: 3) {
                    Text(scene.displayName)
                        .font(.headline)
                    Text("\(controller.sceneAssignments.soundscapes(for: scene).count) 个音景")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: scene.systemImage)
            }
            .padding(.vertical, 6)
            .tag(scene)
        }
        .navigationTitle("白噪音")
    }

    private var nowPlayingPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("当前播放")

            HStack(alignment: .center, spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AppTheme.selectedBackground(for: colorScheme))
                    Image(systemName: controller.selectedSoundscape.systemImage)
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(.tint)
                }
                .frame(width: 112, height: 112)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 28) {
                        playbackMetric("当前场景", controller.selectedScene.displayName)
                        playbackMetric("当前音景", controller.selectedSoundscape.displayName)
                        playbackMetric("状态", playbackStatusText)
                        playbackMetric("剩余时间", controller.remainingText)
                    }

                    HStack(spacing: 12) {
                        Button(primaryPlaybackTitle, systemImage: primaryPlaybackImage) {
                            if controller.playbackState.isActive {
                                controller.stopSession(fadeOut: false)
                            } else {
                                controller.startSelectedSession()
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            if controller.playbackState == .paused {
                                controller.resumeSession()
                            } else {
                                controller.pauseSession()
                            }
                        } label: {
                            Image(systemName: pauseResumeImage)
                                .frame(width: 30)
                        }
                        .help(pauseResumeTitle)
                        .buttonStyle(.bordered)
                        .disabled(!controller.playbackState.isActive)

                        Button {
                            controller.stopSession(fadeOut: false)
                        } label: {
                            Image(systemName: "stop.fill")
                                .frame(width: 30)
                        }
                        .help("停止")
                        .buttonStyle(.bordered)
                        .disabled(!controller.playbackState.isActive)

                        Spacer(minLength: 12)

                        Image(systemName: "speaker.wave.2")
                            .foregroundStyle(.secondary)

                        Slider(
                            value: Binding(
                                get: { Double(controller.volume) },
                                set: { controller.volume = Float($0) }
                            ),
                            in: 0...1
                        )
                        .frame(maxWidth: 320)

                        Text("\(Int(controller.volume * 100))%")
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 42, alignment: .trailing)
                    }
                }
            }

            if let message = controller.lastErrorMessage {
                Label(message, systemImage: "waveform.slash")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .panelStyle(colorScheme: colorScheme)
    }

    private var soundscapePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeader("当前场景音景")
                Spacer()
                Text(controller.selectedScene == .sleep ? "助眠开始时随机选择" : "专注使用当前选择")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: soundscapeColumns, spacing: 12) {
                ForEach(controller.availableSoundscapes) { soundscape in
                    Button {
                        controller.chooseSoundscape(soundscape)
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: soundscape.systemImage)
                                .font(.system(size: 30, weight: .medium))
                            Text(soundscape.displayName)
                                .font(.headline)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 96)
                        .padding(12)
                    }
                    .buttonStyle(SoundscapeTileButtonStyle(isSelected: controller.selectedSoundscape == soundscape, colorScheme: colorScheme))
                }
            }

            durationControl
        }
        .panelStyle(colorScheme: colorScheme)
    }

    private var durationControl: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("时长")
                    .font(.headline)

                Picker("时长", selection: $controller.selectedMinutes) {
                    if controller.selectedScene == .focus {
                        Text("不限").tag(0)
                    }
                    ForEach(SleepTimer.presetMinutes, id: \.self) { minutes in
                        Text("\(minutes)").tag(minutes)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Stepper(value: $controller.customMinutes, in: 1...480, step: 5) {
                    Text("自定义 \(controller.customMinutes) 分钟")
                }
                .disabled(controller.selectedScene == .focus && controller.selectedMinutes == 0)

                Button("应用", systemImage: "checkmark.circle") {
                    controller.startCustomSession()
                }
                .disabled(controller.selectedScene == .focus && controller.selectedMinutes == 0)
            }
        }
    }

    private var libraryPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("媒体库")
                Spacer()
                Text("每个场景至少保留一个可用音景")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 0) {
                GridRow {
                    Text("音景名称")
                        .foregroundStyle(.secondary)
                    Text("助眠")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    Text("专注")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .font(.caption)

                Divider()
                    .gridCellColumns(3)

                ForEach(Soundscape.allCases) { soundscape in
                    GridRow {
                        Label(soundscape.displayName, systemImage: soundscape.systemImage)
                            .frame(minWidth: 220, alignment: .leading)

                        sceneAssignmentToggle(for: soundscape, scene: .sleep)
                            .frame(maxWidth: .infinity)

                        sceneAssignmentToggle(for: soundscape, scene: .focus)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 7)

                    if soundscape != Soundscape.allCases.last {
                        Divider()
                            .gridCellColumns(3)
                    }
                }
            }
            .padding(12)
            .background(AppTheme.panelBackground, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.neutralBorder(for: colorScheme), lineWidth: 0.5)
            }
        }
        .panelStyle(colorScheme: colorScheme)
    }

    private var footerBar: some View {
        HStack(spacing: 14) {
            Toggle(
                isOn: Binding(
                    get: { controller.loginItemService.isEnabled },
                    set: { controller.setLoginItemEnabled($0) }
                )
            ) {
                Label("登录后启动", systemImage: "person.crop.circle.badge.checkmark")
            }
            .toggleStyle(.checkbox)
            .disabled(!controller.loginItemService.isAvailable)

            Text(controller.loginItemService.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Label(controller.focusIntegration.statusMessage, systemImage: "moon.circle")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("测试助眠入口", systemImage: "scope") {
                controller.activateSleepPresetFromFocus()
            }
        }
        .font(.callout)
        .padding(.horizontal, 2)
    }

    private func playbackMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(minWidth: 110, alignment: .leading)
    }

    private func sceneAssignmentToggle(for soundscape: Soundscape, scene: NoiseScene) -> some View {
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
        .labelsHidden()
        .toggleStyle(.checkbox)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }

    private var playbackStatusText: String {
        switch controller.playbackState {
        case .idle:
            return "待机"
        case .preparing:
            return "准备"
        case .playing:
            return "播放中"
        case .paused:
            return "暂停"
        case .error:
            return "需要音频"
        }
    }

    private var primaryPlaybackTitle: String {
        controller.playbackState.isActive ? "停止" : "开始"
    }

    private var primaryPlaybackImage: String {
        controller.playbackState.isActive ? "stop.fill" : "play.fill"
    }

    private var pauseResumeTitle: String {
        controller.playbackState == .paused ? "继续" : "暂停"
    }

    private var pauseResumeImage: String {
        controller.playbackState == .paused ? "play.fill" : "pause.fill"
    }
}

private struct SoundscapeTileButtonStyle: ButtonStyle {
    let isSelected: Bool
    let colorScheme: ColorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(background(isPressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(border, lineWidth: isSelected ? 1.4 : 0.6)
            }
            .contentShape(RoundedRectangle(cornerRadius: 8))
    }

    private func background(isPressed: Bool) -> Color {
        if isPressed {
            return Color.accentColor.opacity(colorScheme == .dark ? 0.34 : 0.20)
        }

        if isSelected {
            return AppTheme.selectedBackground(for: colorScheme)
        }

        return AppTheme.panelBackground
    }

    private var border: Color {
        isSelected
            ? AppTheme.selectedBorder(for: colorScheme)
            : AppTheme.neutralBorder(for: colorScheme)
    }
}

private extension View {
    func panelStyle(colorScheme: ColorScheme) -> some View {
        padding(18)
            .background(AppTheme.windowBackground, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.neutralBorder(for: colorScheme), lineWidth: 0.6)
            }
    }
}
