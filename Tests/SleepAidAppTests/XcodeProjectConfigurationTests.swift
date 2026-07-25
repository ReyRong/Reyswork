import XCTest

final class XcodeProjectConfigurationTests: XCTestCase {
    func testNativeMacAppProjectDeclaresStableAppIdentity() throws {
        let project = try readProjectFile()

        XCTAssertTrue(project.contains("SleepAidApp.app"))
        XCTAssertTrue(project.contains("PRODUCT_BUNDLE_IDENTIFIER = com.rey.whitenoise;"))
        XCTAssertTrue(project.contains("GENERATE_INFOPLIST_FILE = NO;"))
        XCTAssertTrue(project.contains("INFOPLIST_FILE = Sources/SleepAidApp/App/Info.plist;"))
        XCTAssertEqual(try readInfoPlistValue(forKey: "CFBundleDisplayName"), "白噪音")
        XCTAssertEqual(try readInfoPlistValue(forKey: "CFBundleName"), "白噪音")
    }

    func testNativeMacAppProjectOwnsSourcesAndAudioResources() throws {
        let project = try readProjectFile()

        XCTAssertTrue(project.contains("SleepAidApp.swift"))
        XCTAssertTrue(project.contains("WhiteNoiseIntents.swift"))
        XCTAssertTrue(project.contains("cafe.m4a"))
        XCTAssertTrue(project.contains("library.m4a"))
        XCTAssertTrue(project.contains("summer-night.m4a"))
    }

    func testLocalInstallScriptRefreshesLaunchServicesRegistration() throws {
        let scriptURL = repositoryRoot()
            .appendingPathComponent("scripts")
            .appendingPathComponent("install-local.sh")
        let script = try String(contentsOf: scriptURL, encoding: .utf8)

        XCTAssertTrue(script.contains("lsregister"))
        XCTAssertTrue(script.contains("-u \"$DESTINATION\""))
        XCTAssertTrue(script.contains("-f -R -trusted \"$DESTINATION\""))
    }

    private func readProjectFile() throws -> String {
        let projectURL = repositoryRoot()
            .appendingPathComponent("SleepAidApp.xcodeproj")
            .appendingPathComponent("project.pbxproj")
        return try String(contentsOf: projectURL, encoding: .utf8)
    }

    private func readInfoPlistValue(forKey key: String) throws -> String? {
        let plistURL = repositoryRoot()
            .appendingPathComponent("Sources")
            .appendingPathComponent("SleepAidApp")
            .appendingPathComponent("App")
            .appendingPathComponent("Info.plist")
        let plist = try PropertyListSerialization.propertyList(
            from: Data(contentsOf: plistURL),
            options: [],
            format: nil
        )
        return (plist as? [String: Any])?[key] as? String
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
