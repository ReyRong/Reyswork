import XCTest
@testable import SleepAidApp

final class AudioResourceResolverTests: XCTestCase {
    func testMissingBundledSoundscapesThrowResourceMissingErrors() throws {
        for soundscape in Soundscape.allCases {
            XCTAssertThrowsError(try AudioResourceResolver.url(for: soundscape)) { error in
                XCTAssertEqual(error as? AudioPlayerError, .resourceMissing(soundscape))
            }
        }
    }
}
