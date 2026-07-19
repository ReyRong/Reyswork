import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var controller: SleepAidController
    @Environment(\.openWindow) private var openWindow
    @Environment(\.colorScheme) private var colorScheme

    private let quickMinutes = [20, 45, 90]
    private let soundscapeColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            playbackControls

            volumeControl

            sceneControls

            soundscapeControls

            durationControls

            footerControls
        }
        .padding(14)
        .frame(width: 320)
        .background(AppTheme.windowBackground(for: colorScheme))
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: controller.menuBarPresentation.symbolName)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.tint)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 3) {
                Text(controller.menuBarPresentation.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(controller.menuBarPresentation.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 8) {
            Button {
                controller.startSelectedSession()
            } label: {
                Label("开始", systemImage: controller.selectedScene.systemImage)
                    .frame(maxWidth: .infinity)
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
                    .frame(width: 28)
            }
            .help(pauseResumeTitle)
            .buttonStyle(.bordered)
            .disabled(!controller.playbackState.isActive)

            Button {
                controller.stopSession(fadeOut: false)
            } label: {
                Image(systemName: "stop.fill")
                    .frame(width: 28)
            }
            .help("停止")
            .buttonStyle(.bordered)
            .disabled(!controller.playbackState.isActive)
        }
    }

    private var volumeControl: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("音量", systemImage: "speaker.wave.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(controller.volume * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: { Double(controller.volume) },
                    set: { controller.volume = Float($0) }
                ),
                in: 0...1
            )
        }
        .padding(10)
        .background(AppTheme.panelBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 8))
    }

    private var sceneControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("场景")

            HStack(spacing: 8) {
                ForEach(NoiseScene.allCases) { scene in
                    Button {
                        controller.chooseScene(scene)
                    } label: {
                        Label(scene.displayName, systemImage: scene.systemImage)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(MenuPanelButtonStyle(isSelected: controller.selectedScene == scene, colorScheme: colorScheme))
                }
            }
        }
    }

    private var soundscapeControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("音景")

            LazyVGrid(columns: soundscapeColumns, spacing: 8) {
                ForEach(controller.availableSoundscapes) { soundscape in
                    Button {
                        controller.chooseSoundscape(soundscape)
                    } label: {
                        Label(soundscape.displayName, systemImage: soundscape.systemImage)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(MenuPanelButtonStyle(isSelected: controller.selectedSoundscape == soundscape, colorScheme: colorScheme))
                }
            }
        }
    }

    private var durationControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("时长")

            HStack(spacing: 8) {
                if controller.selectedScene == .focus {
                    durationButton(title: "不限", minutes: 0)
                }

                ForEach(quickMinutes, id: \.self) { minutes in
                    durationButton(title: "\(minutes)", minutes: minutes)
                }
            }
        }
    }

    private var footerControls: some View {
        HStack(spacing: 8) {
            Button {
                openWindow(id: "main")
                NSApplication.shared.activate(ignoringOtherApps: true)
            } label: {
                Label("主界面", systemImage: "macwindow")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                openWindow(id: "settings")
                NSApplication.shared.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "gearshape")
                    .frame(width: 28)
            }
            .help("设置")
            .buttonStyle(.bordered)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .frame(width: 28)
            }
            .help("退出")
            .buttonStyle(.bordered)
        }
    }

    private func durationButton(title: String, minutes: Int) -> some View {
        Button {
            controller.startQuickSession(minutes: minutes)
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(MenuPanelButtonStyle(isSelected: controller.selectedMinutes == minutes, colorScheme: colorScheme))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var pauseResumeTitle: String {
        controller.playbackState == .paused ? "继续" : "暂停"
    }

    private var pauseResumeImage: String {
        controller.playbackState == .paused ? "play.fill" : "pause.fill"
    }
}

private struct MenuPanelButtonStyle: ButtonStyle {
    let isSelected: Bool
    let colorScheme: ColorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout)
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .foregroundStyle(isSelected ? Color.primary : Color.primary)
            .background(background(isPressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                if isSelected || colorScheme == .light {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(border, lineWidth: isSelected ? 1 : 0.5)
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
