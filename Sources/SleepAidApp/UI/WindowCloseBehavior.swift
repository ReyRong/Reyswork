import AppKit
import SwiftUI

final class HideInsteadOfCloseWindowDelegate: NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }
}

struct HideInsteadOfCloseWindowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(WindowCloseBehaviorInstaller())
    }
}

private struct WindowCloseBehaviorInstaller: NSViewRepresentable {
    final class Coordinator {
        let delegate = HideInsteadOfCloseWindowDelegate()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        installDelegate(for: view, context: context)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        installDelegate(for: nsView, context: context)
    }

    private func installDelegate(for view: NSView, context: Context) {
        DispatchQueue.main.async {
            view.window?.delegate = context.coordinator.delegate
        }
    }
}

extension View {
    func hideInsteadOfCloseWindow() -> some View {
        modifier(HideInsteadOfCloseWindowModifier())
    }
}
