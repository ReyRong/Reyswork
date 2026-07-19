import Foundation

struct AudioResourceResolver {
    private static let resourceBundleName = "SleepAidApp_SleepAidApp.bundle"

    static func url(for soundscape: Soundscape, bundle: Bundle? = nil) throws -> URL {
        guard let searchBundle = bundle ?? installedResourceBundle() ?? packageResourceBundle() else {
            throw AudioPlayerError.resourceMissing(soundscape)
        }

        for fileExtension in ["m4a", "wav"] {
            if let url = searchBundle.url(forResource: soundscape.assetBaseName, withExtension: fileExtension) {
                return url
            }

            if let url = searchBundle.url(
                forResource: soundscape.assetBaseName,
                withExtension: fileExtension,
                subdirectory: "Audio"
            ) {
                return url
            }
        }

        throw AudioPlayerError.resourceMissing(soundscape)
    }

    static func resourceBundleURL(inAppBundleAt appURL: URL) -> URL? {
        let candidates = [
            appURL.appendingPathComponent("Contents/Resources/\(resourceBundleName)"),
            appURL.appendingPathComponent(resourceBundleName)
        ]

        return candidates.first { Bundle(url: $0) != nil }?.standardizedFileURL
    }

    private static func installedResourceBundle() -> Bundle? {
        guard let url = resourceBundleURL(inAppBundleAt: Bundle.main.bundleURL) else {
            return nil
        }

        return Bundle(url: url)
    }

    private static func packageResourceBundle() -> Bundle? {
        guard Bundle.main.bundleURL.pathExtension != "app" else {
            return nil
        }

        return .module
    }
}
