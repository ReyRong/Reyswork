import Foundation

@MainActor
final class SleepTimer: ObservableObject {
    static let presetMinutes = [20, 45, 60, 90]
    private static let tickInterval: TimeInterval = 1

    @Published private(set) var remainingSeconds: TimeInterval = 0
    @Published private(set) var durationSeconds: TimeInterval = 0
    @Published private(set) var isRunning = false
    @Published private(set) var isPaused = false

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
        isPaused = false

        scheduleTimer()
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        onComplete = nil
        remainingSeconds = 0
        durationSeconds = 0
        isRunning = false
        isPaused = false
    }

    func pause() {
        guard isRunning else {
            return
        }

        tick()
        timer?.invalidate()
        timer = nil
        endDate = nil
        isRunning = false
        isPaused = true
    }

    func resume() {
        guard isPaused, remainingSeconds > 0 else {
            return
        }

        endDate = Date().addingTimeInterval(remainingSeconds)
        isRunning = true
        isPaused = false

        scheduleTimer()
    }

    func formattedRemaining() -> String {
        let totalSeconds = max(0, Int(remainingSeconds.rounded(.up)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func tick() {
        guard let endDate else {
            if isPaused {
                return
            }
            cancel()
            return
        }

        let remaining = max(0, endDate.timeIntervalSinceNow)
        let displayedRemaining = TimeInterval(Int(remaining.rounded(.up)))
        if displayedRemaining != remainingSeconds {
            remainingSeconds = displayedRemaining
        }

        guard remaining <= 0 else {
            return
        }

        let completion = onComplete
        cancel()
        completion?()
    }

    private func scheduleTimer() {
        let newTimer = Timer(timeInterval: Self.tickInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        timer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)
    }
}
