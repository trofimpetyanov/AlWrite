import Foundation
import PencilKit

struct DocumentState: Equatable {
    enum ViewerPosition: Equatable {
        case right
        case left
        case top
        case bottom
    }
    
    enum ViewerProportionState: Equatable {
        case quarter
        case third
        case half
        case twoThirds
        case threeQuarters
        
        var ratio: CGFloat {
            switch self {
            case .quarter: return 0.25
            case .third: return 0.33
            case .half: return 0.5
            case .twoThirds: return 0.66
            case .threeQuarters: return 0.75
            }
        }
    }

    var document: AlWriteDocument?
    var drawing: PKDrawing = PKDrawing()
    var isViewerVisible: Bool = false
    var isToolPickerVisible: Bool = false
    var viewerPosition: ViewerPosition = .right
    var viewerProportion: ViewerProportionState = .half
}

enum DocumentEvent {
    case drawingChanged(PKDrawing)
    case changeViewerPosition(DocumentState.ViewerPosition)
    case changeViewerProportion(DocumentState.ViewerProportionState)
    case toggleViewer
    case toggleToolPicker
}

typealias DocumentViewState = DocumentState
typealias DocumentViewEvent = DocumentEvent 
