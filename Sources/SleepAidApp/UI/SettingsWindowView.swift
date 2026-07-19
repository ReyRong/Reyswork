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
            VStack(alignment: .leading, spacing: 26) {
                section("通用") {
                    settingsRow("默认场景") {
                        Picker("默认场景", selection: $controller.selectedScene) {
                            ForEach(NoiseScene.allCases) { scene in
                                Text(scene.displayName).tag(scene)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 230)
                    }

                    settingsRow("启动时") {
                        Toggle("打开主界面", isOn: $openMainWindowOnLaunch)
                            .toggleStyle(.checkbox)
                    }

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

                    settingsRow("停止时淡出") {
                        Toggle("停止时淡出", isOn: $stopWithFadeOut)
                            .labelsHidden()
                            .toggleStyle(.checkbox)
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
                        .frame(width: 260)
                    }

                    settingsRow("开始方式") {
                        Picker("开始方式", selection: $sleepStartBehavior) {
                            Text(StartBehavior.randomPool.displayName(for: .sleep)).tag(StartBehavior.randomPool.rawValue)
                            Text(StartBehavior.currentSelection.displayName(for: .sleep)).tag(StartBehavior.currentSelection.rawValue)
                        }
                        .frame(width: 260)
                    }
                }

                section("专注") {
                    settingsRow("默认时长（专注）") {
                        Picker("默认时长（专注）", selection: focusDurationBinding) {
                            Text("不限").tag(0)
                            ForEach(SleepTimer.presetMinutes, id: \.self) { minutes in
                                Text("\(minutes)").tag(minutes)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 340)
                    }

                    settingsRow("开始方式") {
                        Picker("开始方式", selection: $focusStartBehavior) {
                            Text(StartBehavior.currentSelection.displayName(for: .focus)).tag(StartBehavior.currentSelection.rawValue)
                            Text(StartBehavior.randomPool.displayName(for: .focus)).tag(StartBehavior.randomPool.rawValue)
                        }
                        .frame(width: 260)
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
        .background(AppTheme.windowBackground(for: colorScheme))
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
                Spacer(minLength: 24)
                content()
                    .frame(maxWidth: 360, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)

            Divider()
                .overlay(AppTheme.divider(for: colorScheme))
                .padding(.leading, 16)
        }
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
