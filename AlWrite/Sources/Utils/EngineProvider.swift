import Foundation
import MyScriptInteractiveInk_Runtime

class EngineProvider {

    static var sharedInstance = EngineProvider()
    var engineErrorMessage: String = ""

    lazy var engine: IINKEngine? = {

        if myCertificate.length == 0 {
            self.engineErrorMessage =
                "Please replace the content of MyCertificate.c with the certificate you received from the developer portal"
            return nil
        }

        let data = Data(bytes: myCertificate.bytes, count: myCertificate.length)
        guard let engine = IINKEngine(certificate: data) else {
            self.engineErrorMessage = "Invalid certificate"
            return nil
        }

        // Get the correct path to recognition assets in the bundle
        print("📂 Bundle path: \(Bundle.main.bundlePath)")
        
        // First try to find recognition assets in the app bundle's Resources directory
        let bundleResourcePath = Bundle.main.resourcePath ?? Bundle.main.bundlePath
        let fileManager = FileManager.default
        
        // Potential paths for the recognition assets
        let possiblePaths = [
            bundleResourcePath + "/Resources/recognition-assets/conf",
            bundleResourcePath + "/recognition-assets/conf",
            Bundle.main.bundlePath + "/recognition-assets/conf"
        ]
        
        var configurationPath = ""
        
        // Check each potential path
        for path in possiblePaths {
            if fileManager.fileExists(atPath: path) {
                print("✅ Recognition assets found at: \(path)")
                configurationPath = path
                break
            }
        }
        
        // If still not found, search deeper and implement fallback
        if configurationPath.isEmpty {
            print("❌ Recognition assets not found at expected locations")
            
            // Search for recognition-assets in the bundle
            print("🔍 Searching for recognition-assets in bundle...")
            
            // Check bundle contents for clues
            do {
                let bundleContents = try fileManager.contentsOfDirectory(atPath: Bundle.main.bundlePath)
                print("📂 Bundle contents: \(bundleContents)")
                
                // Check if "recognition-assets" exists in the bundle
                if bundleContents.contains("recognition-assets") {
                    configurationPath = Bundle.main.bundlePath + "/recognition-assets/conf"
                }
            } catch {
                print("❌ Failed to search bundle: \(error.localizedDescription)")
            }
            
            // If still not found, use a fallback path
            if configurationPath.isEmpty {
                configurationPath = Bundle.main.bundlePath + "/recognition-assets/conf"
                print("⚠️ Using fallback path: \(configurationPath)")
            }
        }
        
        do {
            // Create all directories in the path if they don't exist
            if !configurationPath.isEmpty && !fileManager.fileExists(atPath: configurationPath) {
                try fileManager.createDirectory(atPath: configurationPath, withIntermediateDirectories: true)
                print("📁 Created missing directories for: \(configurationPath)")
            }
            
            try engine.configuration.set(
                stringArray: [configurationPath],
                forKey: "configuration-manager.search-path"
            )
            print("✅ Set configuration search path to: \(configurationPath)")
        } catch {
            print("❌ Failed to set configuration search path: \(error.localizedDescription)")
            return nil
        }

        do {
            try engine.configuration.set(
                string: NSTemporaryDirectory(),
                forKey: "content-package.temp-folder"
            )
        } catch {
            print("Failed to set temporary folder: " + error.localizedDescription)
            return nil
        }

        try? engine.configuration.set(number: 0, forKey: "renderer.drop-shadow.x-offset")
        try? engine.configuration.set(number: 5, forKey: "renderer.drop-shadow.y-offset")
        try? engine.configuration.set(number: 0x0000_0066, forKey: "renderer.drop-shadow.color")
        try? engine.configuration.set(number: 5, forKey: "renderer.drop-shadow.radius")

        return engine
    }()
}
