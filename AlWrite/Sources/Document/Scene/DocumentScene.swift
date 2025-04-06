import Foundation
import PencilKit

struct DocumentState: Equatable {
    enum ViewerPosition: Equatable {
        case right
        case left
        case top
        case bottom
    }

    var document: AlWriteDocument?
    var drawing: PKDrawing = PKDrawing()
    var isViewerVisible: Bool = false
    var isToolPickerVisible: Bool = false
    var viewerPosition: ViewerPosition = .right
}

enum DocumentEvent {
    case drawingChanged(PKDrawing)
    case changeViewerPosition(DocumentState.ViewerPosition)
    case toggleViewer
    case toggleToolPicker
}

typealias DocumentViewState = DocumentState
typealias DocumentViewEvent = DocumentEvent 
