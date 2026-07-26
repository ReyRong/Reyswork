import SwiftUI

struct MainWindowView: View {
    @ObservedObject var controller: SleepAidController
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openWindow) private var openWindow
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sceneSidebar
        } detail: {
            playbackSessionView
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppTheme.windowBackground(for: colorScheme))
        }
        .onChange(of: controller.playbackState.isActive) { isActive in
            withAnimation(.easeInOut(duration: 0.28)) {
                columnVisibility = isActive ? .detailOnly : .all
            }
        }
        .background(AppTheme.windowBackground(for: colorScheme))
        .toolbarBackground(AppTheme.windowBackground(for: colorScheme), for: .windowToolbar)
    }

    private var playbackSessionView: some View {
        let isUnlimited = controller.selectedMinutes == 0

        return ZStack(alignment: .topTrailing) {
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

                if isUnlimited {
                    SessionClockText(fontSize: 82)
                        .monospacedDigit()
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)
                        .padding(.top, 2)
                } else {
                    Text(centralSessionText())
                        .font(.system(size: 96, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)
                        .padding(.top, 2)
                }

                Text(sessionTimeCaption(isUnlimited: isUnlimited))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                sessionSoundscapeSwitcher
                    .padding(.top, 4)
                sessionDurationControl
                sessionVolumeControl
                sessionControls
                    .padding(.top, 4)

                Spacer(minLength: 8)
            }
            .frame(maxWidth: 560, maxHeight: .infinity)
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !isUnlimited {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("当前时间")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    SessionClockText(fontSize: 28)
                        .monospacedDigit()
                }
                .padding(20)
            }

            scenePill
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(AppTheme.windowBackground(for: colorScheme))
        .animation(.easeInOut(duration: 0.22), value: controller.selectedScene)
        .animation(.easeInOut(duration: 0.22), value: controller.selectedSoundscape)
        .animation(.easeInOut(duration: 0.22), value: controller.playbackState.isActive)
    }

    private var sceneSidebar: some View {
        VStack(spacing: 0) {
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
            .scrollContentBackground(.hidden)

            Button("设置...", systemImage: "gearshape") {
                openWindow(id: "settings")
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .navigationTitle("白噪音")
        .navigationSplitViewColumnWidth(min: 150, ideal: 170, max: 190)
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
            if controller.playbackState.isActive {
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
            } else {
                Button("开始", systemImage: "play.fill") {
                    startFromMainSurface()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: [])
                .accessibilityLabel("开始")
            }
        }
    }

    private var sessionDurationControl: some View {
        HStack(spacing: 10) {
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
            .frame(maxWidth: 280)

            HStack(spacing: 6) {
                Text("自定义")
                    .foregroundStyle(.secondary)
                TextField("分钟", value: $controller.customMinutes, formatter: Self.minuteFormatter)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 58)
                Text("分钟")
                    .foregroundStyle(.secondary)
            }

            Button("应用", systemImage: "checkmark.circle") {
                if !controller.playbackState.isActive {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        columnVisibility = .detailOnly
                    }
                }
                controller.startCustomSession()
            }
        }
        .frame(maxWidth: 560)
    }

    private var scenePill: some View {
        Label(controller.selectedScene.displayName, systemImage: controller.selectedScene.systemImage)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(AppTheme.panelBackground(for: colorScheme), in: Capsule())
            .overlay {
                if colorScheme == .light {
                    Capsule()
                        .stroke(AppTheme.neutralBorder(for: colorScheme), lineWidth: 0.6)
                }
            }
    }

    private func startFromMainSurface() {
        withAnimation(.easeInOut(duration: 0.28)) {
            columnVisibility = .detailOnly
        }
        controller.startSelectedSession()
    }

    private func centralSessionText() -> String {
        if controller.playbackState.isActive {
            return controller.remainingText
        }

        return Self.durationFormatter.string(from: TimeInterval(controller.selectedMinutes * 60)) ?? "--:--"
    }

    private func sessionTimeCaption(isUnlimited: Bool) -> String {
        if isUnlimited {
            return controller.playbackState.isActive ? "不限时播放中" : "不限时"
        }

        switch controller.playbackState {
        case .playing, .preparing:
            return "倒计时"
        case .paused:
            return "已暂停"
        case .idle, .error:
            return "预设时长"
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

    private var pauseResumeTitle: String {
        controller.playbackState == .paused ? "继续" : "暂停"
    }

    private var pauseResumeImage: String {
        controller.playbackState == .paused ? "play.fill" : "pause.fill"
    }

    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()

    private static let minuteFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 1
        formatter.maximum = 480
        return formatter
    }()
}

private struct SessionClockText: View {
    let fontSize: CGFloat

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { context in
            Text(Self.formatter.string(from: context.date))
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
        }
    }

    private static let formatter: DateFormatter = {
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
