import XCTest
@testable import SleepAidApp

final class SoundscapeIconTests: XCTestCase {
    func testSummerNightUsesSoftNightIcon() {
        XCTAssertEqual(Soundscape.summerNight.systemImage, "moon.stars.fill")
    }
}
