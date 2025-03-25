import Foundation
import PencilKit

@MainActor
final class HandwritingRecognitionManager {
    private let recognitionEngine: RecognitionEngine
    private var recognitionService: RecognitionService
    
    weak var delegate: HandwritingRecognitionDelegate?
    
    init(engineFactory: RecognitionEngineFactory = RecognitionEngineFactory()) {
        self.recognitionEngine = engineFactory.createDefaultEngine()
        self.recognitionService = recognitionEngine.createRecognizer()
    }
    
    func getRecognitionMode() -> StandardRecognitionMode {
        if let mode = recognitionEngine.currentMode as? StandardRecognitionMode {
            return mode
        }
        return .text
    }
    
    func setRecognitionMode(_ mode: StandardRecognitionMode) {
        recognitionEngine.setMode(mode)
        self.recognitionService = recognitionEngine.createRecognizer()
    }
    
    func processDrawing(_ drawing: PKDrawing) {
        Task {
            do {
                let text = try await recognitionService.processDrawing(drawing)
                delegate?.handwritingRecognitionDidComplete(text: text, error: nil)
            } catch {
                delegate?.handwritingRecognitionDidComplete(text: "", error: error)
            }
        }
    }
    
    func clear() {
        recognitionService.clear()
    }
}