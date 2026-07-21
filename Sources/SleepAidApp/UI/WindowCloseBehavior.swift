import AppKit
import SwiftUI

protocol DockVisibilityControlling: AnyObject {
    func hideDockIcon()
    func showDockIcon()
}

final class AppDockVisibilityController: DockVisibilityControlling {
    func hideDockIcon() {
        Task { @MainActor in
            NSApplication.shared.setActivationPolicy(.accessory)
        }
    }

    func showDockIcon() {
        Task { @MainActor in
            NSApplication.shared.setActivationPolicy(.regular)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
}

enum MainWindowDockPresenter {
    static func showDock(dockVisibility: DockVisibilityControlling = AppDockVisibilityController()) {
        dockVisibility.showDockIcon()
    }
}

final class HideInsteadOfCloseWindowDelegate: NSObject, NSWindowDelegate {
    private let dockVisibility: DockVisibilityControlling

    init(dockVisibility: DockVisibilityControlling = AppDockVisibilityController()) {
        self.dockVisibility = dockVisibility
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        dockVisibility.hideDockIcon()
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

    func restoreWindowContentSize(width: CGFloat, height: CGFloat, when shouldRestore: Bool) -> some View {
        background(WindowContentSizeRestorer(width: width, height: height, shouldRestore: shouldRestore))
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
            window.resizeContentPreservingCenter(width: width, height: height)
            window.center()
        }
    }
}

private struct WindowContentSizeRestorer: NSViewRepresentable {
    let width: CGFloat
    let height: CGFloat
    let shouldRestore: Bool

    final class Coordinator {
        var lastShouldRestore = false
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        restoreSizeIfNeeded(for: view, context: context)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        restoreSizeIfNeeded(for: nsView, context: context)
    }

    private func restoreSizeIfNeeded(for view: NSView, context: Context) {
        let becameActive = shouldRestore && !context.coordinator.lastShouldRestore
        context.coordinator.lastShouldRestore = shouldRestore

        guard becameActive else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            guard let window = view.window else {
                return
            }

            window.resizeContentPreservingCenter(width: width, height: height)
            window.center()
        }
    }
}

private extension NSWindow {
    func resizeContentPreservingCenter(width: CGFloat, height: CGFloat) {
        let currentFrame = frame
        let center = NSPoint(x: currentFrame.midX, y: currentFrame.midY)
        let contentRect = NSRect(origin: .zero, size: NSSize(width: width, height: height))
        var targetFrame = frameRect(forContentRect: contentRect)
        targetFrame.origin = NSPoint(
            x: center.x - targetFrame.width / 2,
            y: center.y - targetFrame.height / 2
        )
        setFrame(targetFrame, display: true)
    }
}
