import Foundation

struct AudioResourceResolver {
    static func url(for soundscape: Soundscape, bundle: Bundle = .module) throws -> URL {
        for fileExtension in ["m4a", "wav"] {
            if let url = bundle.url(forResource: soundscape.assetBaseName, withExtension: fileExtension) {
                return url
            }

            if let url = bundle.url(
                forResource: soundscape.assetBaseName,
                withExtension: fileExtension,
                subdirectory: "Audio"
            ) {
                return url
            }
        }

        throw AudioPlayerError.resourceMissing(soundscape)
    }
}
