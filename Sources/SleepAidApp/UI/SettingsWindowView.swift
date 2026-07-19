import SwiftUI

struct SettingsWindowView: View {
    @ObservedObject var controller: SleepAidController
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("settings.openMainWindowOnLaunch") private var openMainWindowOnLaunch = true
    @AppStorage("settings.stopWithFadeOut") private var stopWithFadeOut = true
    @AppStorage("settings.sleepStartBehavior") private var sleepStartBehavior = StartBehavior.randomPool.rawValue
    @AppStorage("settings.focusStartBehavior") private var focusStartBehavior = StartBehavior.currentSelection.rawValue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                section("通用") {
                    settingsRow("默认场景") {
                        Picker("默认场景", selection: $controller.selectedScene) {
                            ForEach(NoiseScene.allCases) { scene in
                                Text(scene.displayName).tag(scene)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 200)
                    }

                    settingsRow("启动时") {
                        Toggle("打开主界面", isOn: $openMainWindowOnLaunch)
                            .toggleStyle(.checkbox)
                    }

                    settingsRow("默认音量") {
                        HStack(spacing: 12) {
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
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                }

                section("播放") {
                    settingsRow("默认时长（助眠）") {
                        Picker("默认时长（助眠）", selection: sleepDurationBinding) {
                            ForEach([20, 45, 90], id: \.self) { minutes in
                                Text("\(minutes)").tag(minutes)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 220)
                    }

                    settingsRow("开始方式") {
                        Picker("开始方式", selection: $sleepStartBehavior) {
                            Text(StartBehavior.randomPool.displayName(for: .sleep)).tag(StartBehavior.randomPool.rawValue)
                            Text(StartBehavior.currentSelection.displayName(for: .sleep)).tag(StartBehavior.currentSelection.rawValue)
                        }
                        .frame(width: 220)
                    }

                    settingsRow("默认时长（专注）") {
                        Picker("默认时长（专注）", selection: focusDurationBinding) {
                            Text("不限").tag(0)
                            ForEach(SleepTimer.presetMinutes, id: \.self) { minutes in
                                Text("\(minutes)").tag(minutes)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 300)
                    }

                    settingsRow("开始方式") {
                        Picker("开始方式", selection: $focusStartBehavior) {
                            Text(StartBehavior.currentSelection.displayName(for: .focus)).tag(StartBehavior.currentSelection.rawValue)
                            Text(StartBehavior.randomPool.displayName(for: .focus)).tag(StartBehavior.randomPool.rawValue)
                        }
                        .frame(width: 220)
                    }

                    settingsRow("停止时淡出") {
                        Toggle("停止时淡出", isOn: $stopWithFadeOut)
                            .labelsHidden()
                            .toggleStyle(.checkbox)
                    }
                }

                section("媒体库") {
                    HStack {
                        Text("音景")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("助眠")
                            .frame(width: 52)
                        Text("专注")
                            .frame(width: 52)
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .padding(.bottom, 6)

                    ForEach(Soundscape.allCases) { soundscape in
                        mediaLibraryRow(soundscape)
                    }

                    Text("每个场景至少保留一个可用音景。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.top, 6)
                        .padding(.bottom, 12)
                }

                section("系统集成") {
                    settingsRow("登录后启动") {
                        Toggle(
                            "登录后启动",
                            isOn: Binding(
                                get: { controller.loginItemService.isEnabled },
                                set: { controller.setLoginItemEnabled($0) }
                            )
                        )
                        .labelsHidden()
                        .toggleStyle(.checkbox)
                        .disabled(!controller.loginItemService.isAvailable)
                    }

                    infoRow(
                        title: "登录项状态",
                        message: controller.loginItemService.statusMessage,
                        systemImage: "person.crop.circle.badge.checkmark"
                    )

                    infoRow(
                        title: "快捷指令",
                        message: controller.focusIntegration.statusMessage,
                        systemImage: "moon.circle"
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(AppTheme.windowBackground(for: colorScheme))
        .onAppear {
            controller.loginItemService.refreshStatus()
        }
    }

    private var sleepDurationBinding: Binding<Int> {
        Binding(
            get: {
                controller.selectedScene == .sleep ? controller.selectedMinutes : NoiseScene.sleep.defaultMinutes
            },
            set: { minutes in
                controller.chooseScene(.sleep)
                controller.selectedMinutes = minutes
                controller.customMinutes = minutes
            }
        )
    }

    private var focusDurationBinding: Binding<Int> {
        Binding(
            get: {
                controller.selectedScene == .focus ? controller.selectedMinutes : NoiseScene.focus.defaultMinutes
            },
            set: { minutes in
                controller.chooseScene(.focus)
                controller.selectedMinutes = minutes
                controller.customMinutes = minutes
            }
        )
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.semibold))

            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.panelBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.neutralBorder(for: colorScheme), lineWidth: colorScheme == .dark ? 0.35 : 0.5)
            }
        }
    }

    private func settingsRow<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.body)
                Spacer(minLength: 16)
                content()
                    .frame(maxWidth: 300, alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()
                .overlay(AppTheme.divider(for: colorScheme))
                .padding(.leading, 16)
        }
    }

    private func mediaLibraryRow(_ soundscape: Soundscape) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Label(soundscape.displayName, systemImage: soundscape.systemImage)
                    .frame(maxWidth: .infinity, alignment: .leading)

                sceneAssignmentToggle(for: soundscape, scene: .sleep)
                    .frame(width: 52)

                sceneAssignmentToggle(for: soundscape, scene: .focus)
                    .frame(width: 52)
            }
            .font(.callout)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)

            Divider()
                .overlay(AppTheme.divider(for: colorScheme))
                .padding(.leading, 16)
        }
    }

    private func infoRow(title: String, message: String, systemImage: String) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Label(title, systemImage: systemImage)
                    .font(.body)

                Spacer(minLength: 16)

                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 240, alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()
                .overlay(AppTheme.divider(for: colorScheme))
                .padding(.leading, 16)
        }
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
}

private enum StartBehavior: String {
    case randomPool
    case currentSelection

    func displayName(for scene: NoiseScene) -> String {
        switch (self, scene) {
        case (.randomPool, .sleep):
            return "随机播放助眠池"
        case (.randomPool, .focus):
            return "随机播放专注池"
        case (.currentSelection, .sleep):
            return "使用上次助眠音景"
        case (.currentSelection, .focus):
            return "使用当前选择"
        }
    }
}
