import Foundation
import PencilKit

@MainActor
protocol HandwritingRecognizer: AnyObject {
    func setRecognitionMode(_ mode: StandardRecognitionMode)
    func processDrawing(_ drawing: PKDrawing) async throws -> String
}

@MainActor
class HandwritingRecognitionManager: HandwritingRecognizer {
    private let recognitionEngine: RecognitionEngine
    private var recognitionService: RecognitionService
    private var isServiceInitialized = false
    
    init(engineFactory: RecognitionEngineFactory = RecognitionEngineFactory()) {
        self.recognitionEngine = engineFactory.createDefaultEngine()
        self.recognitionService = recognitionEngine.createRecognizer()
    }

    private func reinitializeService() {
        self.recognitionService = recognitionEngine.createRecognizer()
        isServiceInitialized = true
    }
    
    func setRecognitionMode(_ mode: StandardRecognitionMode) {
        recognitionEngine.setMode(mode)
        self.recognitionService = recognitionEngine.createRecognizer()
        isServiceInitialized = true
    }
    
    func processDrawing(_ drawing: PKDrawing) async throws -> String {
        if !isServiceInitialized {
            reinitializeService()
        }

        if drawing.strokes.isEmpty {
            throw RecognitionError.noStrokesToRecognize
        }
        
        do {
            return try await recognitionService.processDrawing(drawing)
        } catch {
            if error is RecognitionError {
                print("Recognition failed, retrying after reinitialization...")
                reinitializeService()
                return try await recognitionService.processDrawing(drawing)
            }
            throw error
        }
    }
}
