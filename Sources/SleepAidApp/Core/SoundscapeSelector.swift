import Foundation

struct SoundscapeSelector {
    static func selectCurrent(
        for scene: NoiseScene,
        current: Soundscape,
        assignments: SoundscapeSceneAssignments,
        randomIndex: (Int) -> Int = { Int.random(in: 0..<$0) }
    ) -> Soundscape {
        let available = assignments.soundscapes(for: scene)
        if available.contains(current) {
            return current
        }

        return select(for: scene, current: current, assignments: assignments, randomIndex: randomIndex)
    }

    static func select(
        for scene: NoiseScene,
        current: Soundscape,
        assignments: SoundscapeSceneAssignments,
        randomIndex: (Int) -> Int = { Int.random(in: 0..<$0) }
    ) -> Soundscape {
        let available = assignments.soundscapes(for: scene)

        if scene == .focus, available.contains(current) {
            return current
        }

        guard !available.isEmpty else {
            return .rain
        }

        let index = min(max(randomIndex(available.count), 0), available.count - 1)
        return available[index]
    }
}
