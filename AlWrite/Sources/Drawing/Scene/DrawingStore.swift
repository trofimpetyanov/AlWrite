import Foundation
import PencilKit

@MainActor
final class DrawingStore: Store {
    @Published private(set) var state: DrawingState
    var statePublisher: Published<DrawingState>.Publisher { $state }

    private let dependenciesContainer: DrawingDependenciesContainer
    private let recognitionManager: HandwritingRecognitionManager
    
    weak var delegate: DrawingStoreDelegate?

    init(
        dependenciesContainer: DrawingDependenciesContainer
    ) {
        self.state = DrawingState()
        self.dependenciesContainer = dependenciesContainer
        self.recognitionManager = HandwritingRecognitionManager(engineFactory: dependenciesContainer.engineFactory)
        self.recognitionManager.delegate = self
    }

    func handle(_ event: DrawingEvent) {
        switch event {
        case .updateDrawing(let drawing):
            state.drawing = drawing ?? PKDrawing()
            
        case .toggleToolPicker:
            state.isToolPickerVisible.toggle()
            
        case .switchRecognitionMode(let mode):
            state.recognitionMode = mode
            recognitionManager.setRecognitionMode(mode)
            
        case .recognizeDrawing(let drawing):
            guard let drawingToProcess = drawing, !drawingToProcess.strokes.isEmpty else {
                delegate?.didCompleteRecognition(result: .failure(RecognitionError.noStrokesToRecognize))
                return
            }
            
            recognitionManager.processDrawing(drawingToProcess)
            
        case .clearDrawing:
            state.drawing = PKDrawing()
            recognitionManager.clear()
        }
    }
}

extension DrawingStore: HandwritingRecognitionDelegate {
    func handwritingRecognitionDidComplete(text: String, error: Error?) {
        if let error = error {
            delegate?.didCompleteRecognition(result: .failure(error))
        } else {
            delegate?.didCompleteRecognition(result: .success(text))
        }
    }
}
