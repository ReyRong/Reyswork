import SwiftUI

enum AppTheme {
    static let darkSurface = Color(red: 24 / 255, green: 24 / 255, blue: 24 / 255)

    static var windowBackground: Color {
        Color(nsColor: .windowBackgroundColor)
    }

    static var panelBackground: Color {
        Color(nsColor: .controlBackgroundColor)
    }

    static var separator: Color {
        Color(nsColor: .separatorColor)
    }

    static func windowBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkSurface : Color(nsColor: .windowBackgroundColor)
    }

    static func panelBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkSurface : Color(nsColor: .controlBackgroundColor)
    }

    static func innerSurface(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkSurface : Color(nsColor: .controlBackgroundColor)
    }

    static func selectedBackground(for colorScheme: ColorScheme) -> Color {
        Color.accentColor.opacity(colorScheme == .dark ? 0.24 : 0.14)
    }

    static func selectedBorder(for colorScheme: ColorScheme) -> Color {
        Color.accentColor.opacity(colorScheme == .dark ? 0.42 : 0.34)
    }

    static func neutralBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.022) : separator.opacity(0.50)
    }

    static func divider(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.025) : separator.opacity(0.45)
    }
}

extension AppTheme {
    static let sleepAccent = Color(red: 0.81, green: 0.74, blue: 0.94)

    static func sceneBackground(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: scheme == .dark
                ? [Color(red: 0.13, green: 0.16, blue: 0.23), Color(red: 0.20, green: 0.22, blue: 0.31), Color(red: 0.20, green: 0.18, blue: 0.29)]
                : [Color(red: 0.88, green: 0.90, blue: 0.95), Color(red: 0.91, green: 0.87, blue: 0.95)],
            startPoint: .topTrailing, endPoint: .bottomLeading
        )
    }
}

extension View {
    @ViewBuilder
    func sleepGlass<S: Shape>(in shape: S, interactive: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            glassEffect(.regular.interactive(interactive), in: shape)
        } else {
            background(.ultraThinMaterial, in: shape)
                .overlay(shape.stroke(.white.opacity(0.18), lineWidth: 0.7))
        }
    }
}
