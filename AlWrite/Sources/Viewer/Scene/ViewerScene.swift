import PencilKit

struct ViewerState: Equatable {
    enum ViewerRecognitionMode: String, Equatable {
        case text = "Текст"
        case math = "Формула"
    }

    var recognizedText: String = ""
    var recognitionMode: ViewerRecognitionMode = .text
    var isLoading: Bool = false
    var isVisible: Bool = false
}

enum ViewerEvent: Equatable {
    case recognizeRequested(PKDrawing)
    case recognitionCompleted(Result<String, Error>)
    case switchRecognitionMode(ViewerState.ViewerRecognitionMode)
    case toggleVisibility

    static func == (lhs: ViewerEvent, rhs: ViewerEvent) -> Bool {
        switch (lhs, rhs) {
        case (.recognizeRequested, .recognizeRequested),
             (.recognitionCompleted, .recognitionCompleted),
             (.toggleVisibility, .toggleVisibility):
            return true
        case (.switchRecognitionMode(let lhs), .switchRecognitionMode(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

typealias ViewerViewState = ViewerState
typealias ViewerViewEvent = ViewerEvent
