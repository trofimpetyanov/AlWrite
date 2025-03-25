import Foundation
import PencilKit

@MainActor
final class HandwritingRecognitionManager {
    private let recognitionEngine: RecognitionEngine
    private var recognitionService: RecognitionService
    private var isServiceInitialized = false
    
    weak var delegate: HandwritingRecognitionDelegate?
    
    init(engineFactory: RecognitionEngineFactory = RecognitionEngineFactory()) {
        self.recognitionEngine = engineFactory.createDefaultEngine()
        self.recognitionService = recognitionEngine.createRecognizer()
    }

    private func reinitializeService() {
        self.recognitionService = recognitionEngine.createRecognizer()
        isServiceInitialized = true
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
        isServiceInitialized = true
    }
    
    func processDrawing(_ drawing: PKDrawing) {
        if !isServiceInitialized {
            reinitializeService()
        }

        if drawing.strokes.isEmpty {
            delegate?.handwritingRecognitionDidComplete(text: "", error: RecognitionError.noStrokesToRecognize)
            return
        }
        
        Task {
            do {
                let text = try await recognitionService.processDrawing(drawing)

                await MainActor.run {
                    delegate?.handwritingRecognitionDidComplete(text: text, error: nil)
                }
            } catch {
                if error is RecognitionError {
                    reinitializeService()
                    
                    do {
                        let text = try await recognitionService.processDrawing(drawing)

                        await MainActor.run {
                            delegate?.handwritingRecognitionDidComplete(text: text, error: nil)
                        }
                        return
                    } catch {
                        await MainActor.run {
                            delegate?.handwritingRecognitionDidComplete(text: "", error: error)
                        }
                    }
                }
                
                await MainActor.run {
                    delegate?.handwritingRecognitionDidComplete(text: "", error: error)
                }
            }
        }
    }
    
    func clear() {
        recognitionService.clear()
    }
}
