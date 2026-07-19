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
