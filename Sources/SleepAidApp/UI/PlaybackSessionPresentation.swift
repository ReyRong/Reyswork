import CoreGraphics
import Foundation

struct PlaybackSessionPresentation {
    let selectedMinutes: Int
    let remainingText: String
    let currentTimeText: String

    var isUnlimited: Bool {
        selectedMinutes == 0
    }

    var centralText: String {
        isUnlimited ? currentTimeText : remainingText
    }

    var showsCornerClock: Bool {
        !isUnlimited
    }
}

struct HoverVolumeState {
    static let collapsedHeight: CGFloat = 48
    static let expandedHeight: CGFloat = 260

    var isHovered = false
    var isDragging = false
    var isKeyboardPresented = false

    var isExpanded: Bool { isHovered || isDragging || isKeyboardPresented }

    func hoverRegion(in bounds: CGRect) -> CGRect {
        guard !bounds.isEmpty, !bounds.isInfinite,
              bounds.origin.x.isFinite, bounds.origin.y.isFinite,
              bounds.width.isFinite, bounds.height.isFinite else { return .null }
        let height = min(bounds.height, isExpanded ? Self.expandedHeight : Self.collapsedHeight)
        return CGRect(x: bounds.minX, y: bounds.midY - height / 2, width: bounds.width, height: height)
            .intersection(bounds)
    }
}
