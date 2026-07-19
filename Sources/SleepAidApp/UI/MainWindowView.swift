import SwiftUI

struct MainWindowView: View {
    @ObservedObject var controller: SleepAidController
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openWindow) private var openWindow
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    private let soundscapeColumns = [
        GridItem(.adaptive(minimum: 124), spacing: 10)
    ]

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sceneSidebar
        } detail: {
            Group {
                if controller.playbackState.isActive {
                    playbackSessionView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.985)),
                            removal: .opacity.combined(with: .offset(y: 8))
                        ))
                } else {
                    controlConsole
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: -8)),
                            removal: .opacity.combined(with: .scale(scale: 0.985))
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppTheme.windowBackground(for: colorScheme))
            .animation(.easeInOut(duration: 0.28), value: controller.playbackState.isActive)
        }
        .onChange(of: controller.playbackState.isActive) { isActive in
            withAnimation(.easeInOut(duration: 0.28)) {
                columnVisibility = isActive ? .detailOnly : .all
            }
        }
        .background(AppTheme.windowBackground(for: colorScheme))
        .toolbarBackground(AppTheme.windowBackground(for: colorScheme), for: .windowToolbar)
    }

    private var controlConsole: some View {
        VStack(alignment: .leading, spacing: 10) {
            nowPlayingPanel
            soundscapePanel
            footerBar
        }
        .padding(14)
    }

    private var playbackSessionView: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { context in
            let clockText = Self.sessionClockFormatter.string(from: context.date)
            let presentation = PlaybackSessionPresentation(
                selectedMinutes: controller.selectedMinutes,
                remainingText: controller.remainingText,
                currentTimeText: clockText
            )

            ZStack(alignment: .topTrailing) {
                VStack(spacing: 16) {
                    Spacer(minLength: 8)

                    sessionIcon

                    VStack(spacing: 5) {
                        Text(controller.selectedScene.displayName)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(controller.selectedSoundscape.displayName)
                            .font(.system(size: 26, weight: .semibold))
                    }

                    Text(presentation.centralText)
                        .font(.system(size: presentation.isUnlimited ? 82 : 96, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)
                        .padding(.top, 2)

                    Text(presentation.isUnlimited ? "不限时" : "倒计时")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    sessionControls
                    sessionVolumeControl
                        .padding(.top, 4)
                    sessionSoundscapeSwitcher
                        .padding(.top, 4)

                    Spacer(minLength: 8)
                }
                .frame(maxWidth: 560, maxHeight: .infinity)
                .padding(.horizontal, 28)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if presentation.showsCornerClock {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("当前时间")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(clockText)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                    }
                    .padding(20)
                }
            }
            .background(AppTheme.windowBackground(for: colorScheme))
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
            sceneSidebarRow(scene)
            .tag(scene)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.sidebar)
        .navigationTitle("白噪音")
        .navigationSplitViewColumnWidth(min: 150, ideal: 170, max: 190)
        .scrollContentBackground(.hidden)
        .background(AppTheme.windowBackground(for: colorScheme))
    }

    private func sceneSidebarRow(_ scene: NoiseScene) -> some View {
        let isSelected = controller.selectedScene == scene

        return HStack(spacing: 10) {
            Image(systemName: scene.systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text(scene.displayName)
                    .font(.headline)
                Text("\(controller.sceneAssignments.soundscapes(for: scene).count) 个音景")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            if isSelected {
                Text("当前")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tint)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            isSelected ? AppTheme.selectedBackground(for: colorScheme) : Color.clear,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }

    private var nowPlayingPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("当前播放")

            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.selectedBackground(for: colorScheme))
                    Image(systemName: controller.selectedSoundscape.systemImage)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.tint)
                }
                .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 14) {
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
                        .keyboardShortcut(.return, modifiers: [])
                        .accessibilityLabel(primaryPlaybackTitle)

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
                        .accessibilityLabel(pauseResumeTitle)
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

                        Spacer(minLength: 8)

                        Image(systemName: "speaker.wave.2")
                            .foregroundStyle(.secondary)

                        Slider(
                            value: Binding(
                                get: { Double(controller.volume) },
                                set: { controller.volume = Float($0) }
                            ),
                            in: 0...1
                        )
                        .frame(maxWidth: 220)

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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionHeader("当前场景音景")
                Spacer()
                Text(controller.selectedScene == .sleep ? "助眠开始时随机选择" : "专注使用当前选择")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: soundscapeColumns, spacing: 10) {
                ForEach(controller.availableSoundscapes) { soundscape in
                    Button {
                        controller.chooseSoundscape(soundscape)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: soundscape.systemImage)
                                .font(.system(size: 23, weight: .medium))
                            Text(soundscape.displayName)
                                .font(.headline)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 62)
                        .padding(8)
                    }
                    .buttonStyle(SoundscapeTileButtonStyle(isSelected: controller.selectedSoundscape == soundscape, colorScheme: colorScheme))
                }
            }

            durationControl
        }
        .panelStyle(colorScheme: colorScheme)
    }

    private var durationControl: some View {
        VStack(alignment: .leading, spacing: 8) {
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

    private var footerBar: some View {
        HStack {
            Button("设置...", systemImage: "gearshape") {
                openWindow(id: "settings")
            }

            Spacer()
        }
        .font(.callout)
        .padding(.horizontal, 2)
    }

    private var sessionIcon: some View {
        ZStack {
            Circle()
                .fill(AppTheme.selectedBackground(for: colorScheme))
            Image(systemName: controller.selectedSoundscape.systemImage)
                .font(.system(size: 46, weight: .semibold))
                .foregroundStyle(.tint)
        }
        .frame(width: 112, height: 112)
    }

    private var sessionControls: some View {
        HStack(spacing: 12) {
            Button {
                if controller.playbackState == .paused {
                    controller.resumeSession()
                } else {
                    controller.pauseSession()
                }
            } label: {
                Label(pauseResumeTitle, systemImage: pauseResumeImage)
                    .frame(width: 92)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(pauseResumeTitle)

            Button("停止", systemImage: "stop.fill") {
                controller.stopSession(fadeOut: false)
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.escape, modifiers: [])
            .accessibilityLabel("停止")
        }
    }

    private var sessionVolumeControl: some View {
        HStack(spacing: 10) {
            Image(systemName: "speaker.wave.2")
                .foregroundStyle(.secondary)

            Slider(
                value: Binding(
                    get: { Double(controller.volume) },
                    set: { controller.volume = Float($0) }
                ),
                in: 0...1
            )

            Text("\(Int(controller.volume * 100))%")
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 42, alignment: .trailing)
        }
        .frame(maxWidth: 340)
    }

    private var sessionSoundscapeSwitcher: some View {
        HStack(spacing: 10) {
            ForEach(controller.availableSoundscapes) { soundscape in
                Button {
                    controller.chooseSoundscape(soundscape)
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: soundscape.systemImage)
                            .font(.system(size: 17, weight: .medium))
                        Text(soundscape.displayName)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .frame(width: 94, height: 50)
                }
                .buttonStyle(SoundscapeTileButtonStyle(isSelected: controller.selectedSoundscape == soundscape, colorScheme: colorScheme))
            }
        }
    }

    private func playbackMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(minWidth: 100, alignment: .leading)
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

    private static let sessionClockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

private struct SoundscapeTileButtonStyle: ButtonStyle {
    let isSelected: Bool
    let colorScheme: ColorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(background(isPressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                if isSelected || colorScheme == .light {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(border, lineWidth: isSelected ? 1.2 : 0.6)
                }
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

        return AppTheme.panelBackground(for: colorScheme)
    }

    private var border: Color {
        isSelected
            ? AppTheme.selectedBorder(for: colorScheme)
            : AppTheme.neutralBorder(for: colorScheme)
    }
}

private extension View {
    func panelStyle(colorScheme: ColorScheme) -> some View {
        padding(14)
            .background(AppTheme.panelBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                if colorScheme == .light {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.neutralBorder(for: colorScheme), lineWidth: 0.6)
                }
            }
    }
}
