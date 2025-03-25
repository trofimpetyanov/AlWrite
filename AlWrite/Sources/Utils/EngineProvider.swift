import Foundation
import MyScriptInteractiveInk_Runtime

final class EngineProvider {

    static var sharedInstance = EngineProvider()
    var engineErrorMessage: String = ""
    static var isEngineInitialized = false

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

        let bundleResourcePath = Bundle.main.resourcePath ?? Bundle.main.bundlePath
        let fileManager = FileManager.default

        let possiblePaths = [
            bundleResourcePath + "/Resources/recognition-assets/conf",
            bundleResourcePath + "/recognition-assets/conf",
            Bundle.main.bundlePath + "/recognition-assets/conf"
        ]
        
        var configurationPath = ""

        for path in possiblePaths {
            if fileManager.fileExists(atPath: path) {
                configurationPath = path
                break
            }
        }

        if configurationPath.isEmpty {
            do {
                let bundleContents = try fileManager.contentsOfDirectory(atPath: Bundle.main.bundlePath)

                if bundleContents.contains("recognition-assets") {
                    configurationPath = Bundle.main.bundlePath + "/recognition-assets/conf"
                }
            } catch {
                print("Failed to search bundle: \(error.localizedDescription)")
            }

            if configurationPath.isEmpty {
                configurationPath = Bundle.main.bundlePath + "/recognition-assets/conf"
            }
        }
        
        do {
            if !configurationPath.isEmpty && !fileManager.fileExists(atPath: configurationPath) {
                try fileManager.createDirectory(atPath: configurationPath, withIntermediateDirectories: true)
            }
            
            try engine.configuration.set(
                stringArray: [configurationPath],
                forKey: "configuration-manager.search-path"
            )
        } catch {
            print("Failed to set configuration search path: \(error.localizedDescription)")
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

        EngineProvider.isEngineInitialized = true
        return engine
    }()
    
    func reloadEngine() -> Bool {
        if let _ = engine {
            EngineProvider.isEngineInitialized = true
            return true
        }
        return false
    }

    private init() { }
}
