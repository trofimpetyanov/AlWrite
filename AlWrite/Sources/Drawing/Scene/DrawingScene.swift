import PencilKit
import UIKit

struct DrawingState: Equatable {
    var drawing: PKDrawing = PKDrawing()
    var isToolPickerVisible: Bool = false
    var recognitionMode: StandardRecognitionMode = .text
}

enum DrawingEvent {
    case updateDrawing(PKDrawing?)
    case toggleToolPicker
    case switchRecognitionMode(StandardRecognitionMode)
    case recognizeDrawing(PKDrawing?)
    case clearDrawing
}

@MainActor
protocol DrawingStoreDelegate: AnyObject {
    func didCompleteRecognition(result: Result<String, Error>)
}

typealias DrawingViewState = DrawingState
typealias DrawingViewEvent = DrawingEvent
