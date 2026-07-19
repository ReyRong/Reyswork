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

    func setInitialWindowContentSize(width: CGFloat, height: CGFloat) -> some View {
        background(WindowInitialSizeInstaller(width: width, height: height))
    }
}

private struct WindowInitialSizeInstaller: NSViewRepresentable {
    let width: CGFloat
    let height: CGFloat

    final class Coordinator {
        var didApplySize = false
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        applySize(for: view, context: context)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        applySize(for: nsView, context: context)
    }

    private func applySize(for view: NSView, context: Context) {
        DispatchQueue.main.async {
            guard !context.coordinator.didApplySize, let window = view.window else {
                return
            }

            context.coordinator.didApplySize = true
            window.setContentSize(NSSize(width: width, height: height))
            window.center()
        }
    }
}
