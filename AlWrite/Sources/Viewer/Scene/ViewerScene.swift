import PencilKit

struct ViewerState: Equatable {
    enum ViewerRecognitionMode: String, Equatable, CaseIterable {
        case text = "Текст"
        case math = "Формула"
    }

    var drawing: PKDrawing = PKDrawing()
    var recognizedText: String = ""
    var recognitionMode: ViewerRecognitionMode = .text
    var isLoading: Bool = false
    var isVisible: Bool = false
}

enum ViewerEvent: Equatable {
    case drawingUpdated(PKDrawing)
    case recognizeRequested
    case switchRecognitionMode(ViewerState.ViewerRecognitionMode)
}

typealias ViewerViewState = ViewerState
typealias ViewerViewEvent = ViewerEvent
