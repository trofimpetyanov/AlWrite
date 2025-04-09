import Foundation
import MyScriptInteractiveInk_Runtime
import PencilKit

final class MyScriptRecognitionEngine: RecognitionEngine {
    private(set) var currentMode: RecognitionMode = StandardRecognitionMode.text
    private let engine: IINKEngine
    private var serviceCache: [String: RecognitionService] = [:]
    
    init() {
        guard let engine = EngineProvider.sharedInstance.engine else {
            fatalError("Failed to initialize IINKEngine: \(EngineProvider.sharedInstance.engineErrorMessage)")
        }
        self.engine = engine
    }
    
    func setMode(_ mode: RecognitionMode) {
        currentMode = mode

        if !serviceCache.isEmpty {
            serviceCache.removeAll()
        }
    }
    
    func createRecognizer() -> RecognitionService {
        let cacheKey = currentMode.mimeTypeString
        
        if let cachedService = serviceCache[cacheKey] {
            return cachedService
        }
        
        let service = MyScriptRecognitionService(engine: engine, mode: currentMode)
        serviceCache[cacheKey] = service
        
        return service
    }
} 
