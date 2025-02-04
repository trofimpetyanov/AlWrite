import PencilKit
import UIKit

struct DrawingState: Equatable {
    var drawing: PKDrawing = PKDrawing()
    var isToolPickerVisible: Bool = false
}

enum DrawingEvent {
    case updateDrawing(PKDrawing?)
    case toggleToolPicker
}

typealias DrawingViewState = DrawingState
typealias DrawingViewEvent = DrawingEvent
