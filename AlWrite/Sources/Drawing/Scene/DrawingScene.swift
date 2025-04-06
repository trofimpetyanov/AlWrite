import SwiftUI
import PencilKit

struct DrawingState: Equatable {
    var drawing: PKDrawing = PKDrawing()
    var isToolPickerVisible: Bool = false
}

enum DrawingEvent {
    case drawingChanged(PKDrawing)
    case toggleToolPicker(Bool)
}

typealias DrawingViewState = DrawingState
typealias DrawingViewEvent = DrawingEvent
