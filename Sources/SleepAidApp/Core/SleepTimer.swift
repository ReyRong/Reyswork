import Foundation

@MainActor
final class SleepTimer: ObservableObject {
    static let presetMinutes = [20, 45, 90]

    @Published private(set) var remainingSeconds: TimeInterval = 0
    @Published private(set) var durationSeconds: TimeInterval = 0
    @Published private(set) var isRunning = false

    private var timer: Timer?
    private var endDate: Date?
    private var onComplete: (() -> Void)?

    deinit {
        timer?.invalidate()
    }

    func start(duration: TimeInterval, onComplete: @escaping () -> Void) {
        cancel()

        let clampedDuration = max(duration, 1)
        durationSeconds = clampedDuration
        remainingSeconds = clampedDuration
        endDate = Date().addingTimeInterval(clampedDuration)
        self.onComplete = onComplete
        isRunning = true

        let newTimer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        timer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        onComplete = nil
        remainingSeconds = 0
        durationSeconds = 0
        isRunning = false
    }

    func formattedRemaining() -> String {
        let totalSeconds = max(0, Int(remainingSeconds.rounded(.up)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func tick() {
        guard let endDate else {
            cancel()
            return
        }

        let remaining = max(0, endDate.timeIntervalSinceNow)
        remainingSeconds = remaining

        guard remaining <= 0 else {
            return
        }

        let completion = onComplete
        cancel()
        completion?()
    }
}
