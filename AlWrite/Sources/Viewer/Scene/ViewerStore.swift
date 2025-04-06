import Foundation
import PencilKit
import Combine

@MainActor
final class ViewerStore: Store {
    @Published private(set) var state: ViewerState
    var statePublisher: Published<ViewerState>.Publisher { $state }
    
    private let dependenciesContainer: ViewerDependenciesContainer
    private let recognitionManager: HandwritingRecognizer
    
    private var debounceTask: Task<Void, Never>?
    private let debounceInterval: TimeInterval = 0.8
    
    init(dependenciesContainer: ViewerDependenciesContainer) {
        self.state = ViewerState()
        self.dependenciesContainer = dependenciesContainer
        self.recognitionManager = dependenciesContainer.recognitionManager
        recognitionManager.delegate = self
    }
    
    func handle(_ event: ViewerEvent) {
        switch event {
        case .appeared:
            state.recognizedText = ""
            debouncedRecognize(drawing: state.drawing)
        case .drawingUpdated(let drawing):
            state.drawing = drawing
            debouncedRecognize(drawing: drawing)
        case .switchRecognitionMode(let mode):
            state.recognitionMode = mode
            state.recognizedText = ""
            recognitionManager.setRecognitionMode(convertToStandardMode(mode))
            handleRecognizeRequested()
        case .recognizeRequested:
            state.recognizedText = ""
            handleRecognizeRequested()
        }
    }
    
    private func debouncedRecognize(drawing: PKDrawing) {
        debounceTask?.cancel()
        
        debounceTask = Task { [weak self] in
            do {
                guard let self else { return }
                try await Task.sleep(for: .seconds(debounceInterval))
                try Task.checkCancellation()
                handleRecognizeRequested()
            } catch {
                return
            }
        }
    }
    
    private func handleRecognizeRequested() {
        if state.drawing.strokes.isEmpty {
            handleRecognitionCompleted(.failure(RecognitionError.noStrokesToRecognize))
            return
        }
        
        state.isLoading = true
        recognitionManager.processDrawing(state.drawing)
    }
    
    private func handleRecognitionCompleted(_ result: Result<String, Error>) {
        state.isLoading = false
        
        switch result {
        case .success(let text):
            state.recognizedText = text
        case .failure(_):
            state.recognizedText = "Не удалось распознать текст"
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
