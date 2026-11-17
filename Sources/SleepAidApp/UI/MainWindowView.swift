import AppKit
import SwiftUI

struct MainWindowView: View {
    @ObservedObject var controller: SleepAidController
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openWindow) private var openWindow
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showsDuration = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sceneSidebar
        } detail: {
            GeometryReader { geometry in
                let dense = controller.availableSoundscapes.count > 4
                let compact = geometry.size.height < 660 || dense
                VStack(spacing: compact ? 14 : 18) {
                        sessionHeading
                        sessionHero(compact: compact, dense: dense)
                            .frame(maxHeight: .infinity)
                        soundscapeCards(compact: dense)
                        if let error = controller.lastErrorMessage {
                            Text(error).font(.callout).foregroundStyle(.red)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.leading, 30)
                    .padding(.trailing, 76)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(AppTheme.sceneBackground(for: colorScheme))
            .navigationTitle(controller.selectedScene.displayName)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        openWindow(id: "settings")
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .help("设置")
                    .accessibilityLabel("打开设置")
                    .keyboardShortcut(",", modifiers: .command)
                }
            }
        }
        .tint(colorScheme == .dark ? AppTheme.sleepAccent : .purple)
        .toolbarBackground(.ultraThinMaterial, for: .windowToolbar)
        .onChange(of: controller.playbackState.isActive) { active in
            withAnimation(.easeInOut(duration: 0.25)) {
                columnVisibility = active ? .detailOnly : .all
            }
        }
        .sheet(isPresented: $showsDuration) {
            SessionDurationSheet(controller: controller)
        }
    }

    private var sceneSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 11) {
                Image(systemName: "waveform")
                    .font(.title2)
                    .frame(width: 42, height: 42)
                    .sleepGlass(in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 5) {
                    Text("白噪音").font(.headline)
                    Text("留一点安静给自己").font(.system(size: 10)).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 28)
            .padding(.bottom, 32)

            Text("你的空间").font(.caption2).foregroundStyle(.secondary)
                .padding(.horizontal, 22).padding(.bottom, 10)
            ForEach(NoiseScene.allCases) { scene in
                Button {
                    controller.chooseScene(scene)
                } label: {
                    sidebarRow(scene)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
            }
            Spacer(minLength: 24)
            VStack(alignment: .leading, spacing: 14) {
                Text("LESS NOISE. MORE PEACE.")
                    .font(.system(size: 8)).tracking(0.8)
                Text("世界很大，\n此刻只需听见自己。")
                    .font(.caption).lineSpacing(5)
            }
            .foregroundStyle(.secondary)
            .padding(22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.ultraThinMaterial)
        .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 240)
    }

    private func sidebarRow(_ scene: NoiseScene) -> some View {
        let selected = scene == controller.selectedScene
        return HStack(spacing: 11) {
            Image(systemName: scene.systemImage).font(.system(size: 19))
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 5) {
                Text(scene.displayName).font(.system(size: 14, weight: .medium))
                Text(scene == .sleep ? "慢下来，好好休息" : "让注意力回到此刻")
                    .font(.system(size: 10)).foregroundStyle(.secondary)
            }
            Spacer(minLength: 2)
            if selected { Circle().fill(.tint).frame(width: 4, height: 4) }
        }
        .padding(14)
        .background(selected ? AppTheme.sleepAccent.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(.primary.opacity(selected ? 0.15 : 0), lineWidth: 0.7)
        }
        .contentShape(RoundedRectangle(cornerRadius: 15))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var sessionHeading: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 9) {
                Text(controller.selectedScene == .sleep ? "A LITTLE QUIET, JUST FOR YOU" : "MAKE ROOM FOR YOUR MIND")
                    .font(.system(size: 8)).tracking(1.4).foregroundStyle(.secondary)
                Text(controller.selectedScene == .sleep ? "把今天，轻轻放下。" : "心无旁骛，就在此刻。")
                    .font(.system(size: 23, weight: .regular))
            }
            Spacer(minLength: 12)
            if controller.selectedMinutes != 0 {
                VStack(alignment: .trailing, spacing: 5) {
                    Text("当前时间").font(.system(size: 9)).foregroundStyle(.secondary)
                    SessionClockText(fontSize: 20)
                }
            }
        }
    }

    private func sessionHero(compact: Bool, dense: Bool) -> some View {
        VStack(spacing: dense ? 6 : compact ? 8 : 11) {
            ZStack {
                Circle().stroke(.primary.opacity(0.07), lineWidth: 0.7)
                Circle().stroke(.primary.opacity(0.08), lineWidth: 0.7).padding(12)
                Image(systemName: controller.selectedScene == .sleep ? "moon" : "scope")
                    .font(.system(size: dense ? 28 : compact ? 32 : 43, weight: .ultraLight))
                    .foregroundStyle(colorScheme == .dark ? AppTheme.sleepAccent : .purple)
                    .frame(width: dense ? 52 : compact ? 64 : 82, height: dense ? 52 : compact ? 64 : 82)
                    .sleepGlass(in: Circle())
            }
            .frame(width: dense ? 76 : compact ? 104 : 136, height: dense ? 76 : compact ? 104 : 136)

            HStack(spacing: 6) {
                Circle().fill(controller.playbackState == .playing ? Color.green.opacity(0.7) : .secondary)
                    .frame(width: 4, height: 4)
                Text(statusTitle)
                Text("·")
                Text(controller.selectedSoundscape.displayName)
            }
            .font(.system(size: 11)).foregroundStyle(.secondary)

            Button { showsDuration = true } label: {
                Group {
                    if controller.selectedMinutes == 0 {
                        SessionClockText(fontSize: dense ? 60 : compact ? 68 : 80)
                    } else {
                        Text(centralSessionText)
                            .font(.system(size: dense ? 64 : compact ? 76 : 86, weight: .ultraLight))
                    }
                }
                .monospacedDigit().minimumScaleFactor(0.7).lineLimit(1)
                .padding(.horizontal, 8)
            }
            .buttonStyle(.plain)
            .help("点击设置时长")
            .accessibilityLabel("设置播放时长")
            .accessibilityValue(controller.selectedMinutes == 0 ? "不限时" : centralSessionText)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                HoverVolumeControl(volume: Binding(
                    get: { Double(controller.volume) },
                    set: { controller.volume = Float($0) }
                ))
                .offset(x: 62)
            }
            .zIndex(1)

            Text(sessionCaption).font(.system(size: 10)).foregroundStyle(.secondary)
            sessionControls.padding(.top, compact ? 9 : 14)
        }
        .padding(.vertical, compact ? 5 : 10)
    }

    private var sessionControls: some View {
        HStack(spacing: 12) {
            Button {
                if controller.playbackState == .paused { controller.resumeSession() }
                else if controller.playbackState.isActive { controller.pauseSession() }
                else { controller.startSelectedSession() }
            } label: {
                Label(playTitle, systemImage: controller.playbackState == .playing ? "pause.fill" : "play.fill")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 27).padding(.vertical, 12)
                    .sleepGlass(in: Capsule(), interactive: true)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: [])
            if controller.playbackState.isActive {
                Button {
                    controller.stopSession(fadeOut: false)
                } label: {
                    Image(systemName: "stop.fill").font(.system(size: 13))
                        .frame(width: 40, height: 40)
                        .sleepGlass(in: Circle(), interactive: true)
                }
                .buttonStyle(.plain).help("停止")
                .accessibilityLabel("停止播放")
                .keyboardShortcut(.escape, modifiers: [])
            }
        }
    }

    private func soundscapeCards(compact: Bool) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("此刻的声音").font(.system(size: 12, weight: .medium))
                Text("\(controller.availableSoundscapes.count) 个音景")
                    .font(.system(size: 9)).foregroundStyle(.secondary)
                Spacer()
                Button {
                    if let next = controller.availableSoundscapes.filter({ $0 != controller.selectedSoundscape }).randomElement() {
                        controller.chooseSoundscape(next)
                    }
                } label: {
                    Label("随机换一个", systemImage: "shuffle").font(.system(size: 10))
                }
                .buttonStyle(.plain).foregroundStyle(.secondary)
                .disabled(controller.availableSoundscapes.count < 2)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: min(controller.availableSoundscapes.count, compact ? 3 : 4)), spacing: 10) {
                ForEach(controller.availableSoundscapes) { soundscape in
                    soundscapeCard(soundscape, compact: compact)
                }
            }
        }
    }

    private func soundscapeCard(_ soundscape: Soundscape, compact: Bool) -> some View {
        let selected = soundscape == controller.selectedSoundscape
        return Button { controller.chooseSoundscape(soundscape) } label: {
            VStack(alignment: .leading, spacing: compact ? 5 : 7) {
                HStack {
                    Image(systemName: soundscape.systemImage)
                        .font(.system(size: compact ? 19 : 23, weight: .light))
                        .foregroundStyle(soundscapeColor(soundscape))
                    Spacer(minLength: 0)
                    if selected { Image(systemName: "checkmark").font(.system(size: 10)) }
                }
                Text(soundscape.displayName).font(.system(size: 11, weight: .medium)).lineLimit(1)
                Text(selected ? "当前音景" : soundscape.detail)
                    .font(.system(size: 9)).foregroundStyle(.secondary).lineLimit(1)
            }
            .padding(compact ? 10 : 13).frame(maxWidth: .infinity, alignment: .leading)
            .sleepGlass(in: RoundedRectangle(cornerRadius: 17), interactive: true)
            .overlay {
                RoundedRectangle(cornerRadius: 17)
                    .stroke(selected ? AppTheme.sleepAccent.opacity(0.65) : .clear, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 17))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func soundscapeColor(_ soundscape: Soundscape) -> Color {
        switch soundscape {
        case .ocean, .rain: return Color(red: 0.61, green: 0.77, blue: 0.87)
        case .fireplace, .cafe: return Color(red: 0.87, green: 0.70, blue: 0.54)
        case .summerNight: return AppTheme.sleepAccent
        case .library: return Color(red: 0.65, green: 0.78, blue: 0.68)
        }
    }

    private var centralSessionText: String {
        if controller.playbackState.isActive { return controller.remainingText }
        return String(format: "%02d:00", controller.selectedMinutes)
    }

    private var statusTitle: String {
        switch controller.playbackState {
        case .idle: return "准备就绪"
        case .preparing: return "准备播放"
        case .playing: return "正在播放"
        case .paused: return "已暂停"
        case .error: return "播放失败"
        }
    }

    private var playTitle: String {
        if controller.playbackState == .paused { return "继续播放" }
        if controller.playbackState.isActive { return "暂停" }
        return controller.selectedScene == .sleep ? "开始助眠" : "开始专注"
    }

    private var sessionCaption: String {
        if controller.selectedMinutes == 0 { return "不限时 · 跟随自己的节奏" }
        if controller.playbackState == .paused { return "时间已暂停，安静等你回来" }
        return controller.playbackState.isActive ? "剩余时间 · 结束时柔和淡出" : "分钟后结束 · 让声音陪你慢下来"
    }
}

private struct SessionClockText: View {
    let fontSize: CGFloat

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { context in
            Text(context.date, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
                .font(.system(size: fontSize, weight: .ultraLight)).monospacedDigit()
        }
    }
}

private struct SessionDurationSheet: View {
    @ObservedObject var controller: SleepAidController
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var edited = false
    @State private var error: String?
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "timer").font(.title2).foregroundStyle(.secondary)
            Text("播放时长").font(.title3.weight(.medium))
            Text("选择或输入时长，结束后自动停止。")
                .font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(controller.selectedScene == .focus ? [0, 20, 45, 90] : [20, 45, 90], id: \.self) { minutes in
                    Button(minutes == 0 ? "不限时" : "\(minutes) 分钟") {
                        controller.setSessionDuration(minutes: minutes)
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(controller.selectedMinutes == minutes ? .purple : .secondary)
                }
            }
            Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 14) {
                GridRow {
                    Text("播放时长").font(.callout)
                    TextField("分钟", text: Binding(
                        get: { draft },
                        set: { draft = $0; edited = true; error = nil }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 110, height: 36)
                    .focused($inputFocused)
                    .onSubmit(apply)
                    .accessibilityLabel("播放时长（分钟）")
                    Text("分钟").font(.callout)
                }
                GridRow {
                    Color.clear.frame(width: 1, height: 1)
                    Text(error ?? "可设置 1–720 分钟")
                        .font(.system(size: 10))
                        .foregroundStyle(error == nil ? Color.secondary : .red)
                        .frame(width: 165, alignment: .leading)
                        .gridCellColumns(2)
                }
            }
            .padding(.top, 4)
            HStack(spacing: 16) {
                Spacer()
                Button("取消") { dismiss() }.keyboardShortcut(.cancelAction)
                Button("应用时长", action: apply)
                    .buttonStyle(.borderedProminent).disabled(!edited)
            }
            .padding(.top, 8)
        }
        .padding(28).frame(width: 390)
        .onAppear { draft = String(controller.selectedMinutes); inputFocused = true }
        .onExitCommand { dismiss() }
    }

    private func apply() {
        guard edited else { return }
        guard let minutes = SessionDurationInput.minutes(from: draft, scene: controller.selectedScene), minutes > 0 else {
            error = "请输入 1–720 之间的整数"
            return
        }
        controller.setSessionDuration(minutes: minutes)
        dismiss()
    }
}

private struct HoverVolumeControl: View {
    @Binding var volume: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var state = HoverVolumeState()
    @State private var volumeBeforeMute = 0.4
    private enum FocusedControl: Hashable { case trigger, slider, mute }
    @FocusState private var focusedControl: FocusedControl?

    var body: some View {
        ZStack {
                VStack(spacing: 14) {
                    Text("\(Int((volume * 100).rounded()))%")
                        .font(.system(size: 10).monospacedDigit())
                    NativeVerticalVolumeSlider(value: $volume, onEditingChanged: { editing in
                        state.isDragging = editing
                    })
                    .frame(width: 24, height: 112)
                    .accessibilityLabel("音量")
                    .focused($focusedControl, equals: .slider)
                    Button(action: toggleMute) {
                        Image(systemName: volume == 0 ? "speaker.slash" : "speaker.wave.2")
                            .font(.system(size: 14)).frame(width: 32, height: 28)
                    }
                    .buttonStyle(.plain)
                    .focused($focusedControl, equals: .mute)
                    .accessibilityLabel(volume == 0 ? "取消静音" : "静音")
                }
                .padding(.vertical, 16)
                .frame(width: 48, height: HoverVolumeState.expandedHeight - HoverVolumeState.collapsedHeight)
                .sleepGlass(in: Capsule())
                .offset(y: -HoverVolumeState.collapsedHeight / 2)
                .opacity(state.isExpanded ? 1 : 0)
                .scaleEffect(state.isExpanded || reduceMotion ? 1 : 0.96)
                .allowsHitTesting(state.isExpanded)
                .accessibilityHidden(!state.isExpanded)
                .disabled(!state.isExpanded)
            Button {
                state.isKeyboardPresented.toggle()
            } label: {
                Image(systemName: volume == 0 ? "speaker.slash" : "speaker.wave.2")
                    .font(.system(size: 17, weight: .light))
                    .frame(width: 44, height: 48)
                    .sleepGlass(in: Capsule(), interactive: true)
            }
            .buttonStyle(.plain)
            .opacity(state.isExpanded || focusedControl != nil ? 1 : 0.35)
            .focused($focusedControl, equals: .trigger)
            .accessibilityLabel("音量调节")
            .accessibilityValue("\(Int(volume * 100))%")
            .offset(y: state.isExpanded ? (HoverVolumeState.expandedHeight - HoverVolumeState.collapsedHeight) / 2 : 0)
        }
        .frame(width: 48, height: HoverVolumeState.expandedHeight)
        .contentShape(Rectangle())
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.26, dampingFraction: 1), value: state.isExpanded)
        .onContinuousHover { phase in
            let hovered: Bool
            switch phase {
            case .active(let location):
                hovered = state.hoverRegion(in: CGRect(x: 0, y: 0, width: 48, height: HoverVolumeState.expandedHeight)).contains(location)
            case .ended:
                hovered = false
            }
            if state.isHovered != hovered { state.isHovered = hovered }
            if !hovered, state.isKeyboardPresented { state.isKeyboardPresented = false }
        }
        .onChange(of: focusedControl) { focused in
            state.isKeyboardPresented = focused != nil
        }
        .onExitCommand { state.isKeyboardPresented = false }
    }

    private func toggleMute() {
        if volume > 0 { volumeBeforeMute = volume; volume = 0 }
        else { volume = volumeBeforeMute }
    }
}


private struct NativeVerticalVolumeSlider: NSViewRepresentable {
    @Binding var value: Double
    let onEditingChanged: (Bool) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(value: $value) }

    func makeNSView(context: Context) -> TrackingVolumeSlider {
        let slider = TrackingVolumeSlider(value: value, minValue: 0, maxValue: 1,
                                          target: context.coordinator, action: #selector(Coordinator.changed(_:)))
        slider.isVertical = true
        slider.isContinuous = true
        slider.onEditingChanged = onEditingChanged
        slider.setAccessibilityLabel("音量")
        return slider
    }

    func updateNSView(_ slider: TrackingVolumeSlider, context: Context) {
        context.coordinator.value = $value
        slider.onEditingChanged = onEditingChanged
        if !slider.isTrackingMouse {
            slider.doubleValue = min(max(value, 0), 1)
        }
    }

    @MainActor
    final class Coordinator: NSObject {
        var value: Binding<Double>
        init(value: Binding<Double>) { self.value = value }
        @objc func changed(_ sender: NSSlider) { value.wrappedValue = sender.doubleValue }
    }
}

private final class TrackingVolumeSlider: NSSlider {
    var onEditingChanged: ((Bool) -> Void)?
    private(set) var isTrackingMouse = false

    override func mouseDown(with event: NSEvent) {
        isTrackingMouse = true
        onEditingChanged?(true)
        defer {
            isTrackingMouse = false
            onEditingChanged?(false)
        }
        super.mouseDown(with: event)
    }
}
