import XCTest
@testable import SleepAidApp

final class AudioResourceResolverTests: XCTestCase {
    func testBundledSoundscapesResolveToAudioFiles() throws {
        for soundscape in Soundscape.allCases {
            let url = try AudioResourceResolver.url(for: soundscape)

            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            XCTAssertEqual(url.pathExtension, "m4a")
            XCTAssertEqual(url.deletingPathExtension().lastPathComponent, soundscape.assetBaseName)
        }
    }

    func testMissingSoundscapeThrowsResourceMissingErrorForEmptyBundle() throws {
        let emptyBundle = Bundle(for: AudioResourceResolverTests.self)

        XCTAssertThrowsError(try AudioResourceResolver.url(for: .ocean, bundle: emptyBundle)) { error in
            XCTAssertEqual(error as? AudioPlayerError, .resourceMissing(.ocean))
        }
    }

    func testFindsResourceBundleInsideInstalledAppResourcesLayout() throws {
        let appURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("app")
        let bundleURL = appURL
            .appendingPathComponent("Contents/Resources/SleepAidApp_SleepAidApp.bundle")
        try FileManager.default.createDirectory(at: bundleURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: appURL) }

        XCTAssertEqual(
            AudioResourceResolver.resourceBundleURL(inAppBundleAt: appURL),
            bundleURL.standardizedFileURL
        )
    }
}
