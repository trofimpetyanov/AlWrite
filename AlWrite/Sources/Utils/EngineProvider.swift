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

        let configurationPath = Bundle.main.bundlePath.appending("/recognition-assets/conf")
        do {
            try engine.configuration.set(
                stringArray: [configurationPath],
                forKey: "configuration-manager.search-path"
            )
        } catch {
            print("Should not happen, please check your resources assets : ", error.localizedDescription)
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
