import SwiftUI

enum AppTheme {
    static var windowBackground: Color {
        Color(nsColor: .windowBackgroundColor)
    }

    static var panelBackground: Color {
        Color(nsColor: .controlBackgroundColor)
    }

    static var separator: Color {
        Color(nsColor: .separatorColor)
    }

    static func selectedBackground(for colorScheme: ColorScheme) -> Color {
        Color.accentColor.opacity(colorScheme == .dark ? 0.28 : 0.14)
    }

    static func selectedBorder(for colorScheme: ColorScheme) -> Color {
        Color.accentColor.opacity(colorScheme == .dark ? 0.62 : 0.34)
    }

    static func neutralBorder(for colorScheme: ColorScheme) -> Color {
        separator.opacity(colorScheme == .dark ? 0.70 : 0.50)
    }
}
