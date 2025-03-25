import Foundation
import PencilKit
import Combine

@MainActor
final class ViewerStore: Store {
    @Published private(set) var state: ViewerState
    var statePublisher: Published<ViewerState>.Publisher { $state }

    private let dependenciesContainer: ViewerDependenciesContainer
    private let recognitionManager: HandwritingRecognitionManager

    private var currentDrawing: PKDrawing?

    init(dependenciesContainer: ViewerDependenciesContainer) {
        self.state = ViewerState()
        self.dependenciesContainer = dependenciesContainer
        self.recognitionManager = dependenciesContainer.recognitionManager
    }

    func handle(_ event: ViewerEvent) {
        switch event {
        case .recognizeRequested(let drawing):
            handleRecognizeRequested(drawing)

        case .recognitionCompleted(let result):
            handleRecognitionCompleted(result)

        case .switchRecognitionMode(let mode):
            state.recognitionMode = mode
            recognitionManager.setRecognitionMode(convertToStandardMode(mode))

        case .toggleVisibility:
            state.isVisible.toggle()
        }
    }

    private func handleRecognizeRequested(_ drawing: PKDrawing) {
        if drawing.strokes.isEmpty {
            handleRecognitionCompleted(.failure(RecognitionError.noStrokesToRecognize))
            return
        }

        state.isLoading = true
        dependenciesContainer.recognitionManager.processDrawing(drawing)
    }

    private func handleRecognitionCompleted(_ result: Result<String, Error>) {
        state.isLoading = false

        switch result {
        case .success(let text):
            state.recognizedText = text
            if state.isVisible {
                state.isVisible = true
            }
        case .failure(_):
            state.recognizedText = "Не удалось распознать текст"
            if state.isVisible {
                state.isVisible = true
            }
        }
    }
    
    private func convertToStandardMode(_ mode: ViewerState.ViewerRecognitionMode) -> StandardRecognitionMode {
        return mode == .text ? .text : .math
    }
}

// MARK: - HandwritingRecognitionDelegate
extension ViewerStore: HandwritingRecognitionDelegate {
    func handwritingRecognitionDidComplete(text: String, error: Error?) {
        if let error = error {
            handleRecognitionCompleted(.failure(error))
        } else {
            if text.isEmpty {
                handleRecognitionCompleted(.success("Документ пустой!"))
            } else {
                handleRecognitionCompleted(.success(text))
            }
        }
    }
}
