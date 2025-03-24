import Foundation
import MyScriptInteractiveInk_Runtime
import PencilKit

final class MyScriptRecognitionEngine: RecognitionEngine {
    private(set) var currentMode: RecognitionMode = StandardRecognitionMode.text
    private let engine: IINKEngine
    
    init() {
        guard let engine = EngineProvider.sharedInstance.engine else {
            fatalError("Failed to initialize IINKEngine: \(EngineProvider.sharedInstance.engineErrorMessage)")
        }
        self.engine = engine
    }
    
    func setMode(_ mode: RecognitionMode) {
        currentMode = mode
    }
    
    func createRecognizer() -> RecognitionService {
        MyScriptRecognitionService(engine: engine, mode: currentMode)
    }
} 