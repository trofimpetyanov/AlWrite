import Foundation
import PencilKit
import Combine

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
    var blocks: [DrawingBlock] = []
    var isViewerVisible: Bool = false
    var isToolPickerVisible: Bool = false
    var viewerPosition: ViewerPosition = .right
    var viewerProportion: ViewerProportionState = .half

    var isRecognitionLoading: Bool = false
    var combinedRecognizedText: String = ""
}

enum DocumentEvent {
    case setDocument(AlWriteDocument)
    case documentLoaded(blocks: [DrawingBlock])
    
    case addBlock(type: DrawingBlock.BlockType)
    case deleteRequested(id: UUID)
    case updateBlockDrawing(id: UUID, drawing: PKDrawing)
    
    case recognitionProcessNeeded
    case recognitionCompleted(Result<String, Error>)

    case changeViewerPosition(DocumentState.ViewerPosition)
    case changeViewerProportion(DocumentState.ViewerProportionState)
    case toggleViewer
    case toggleToolPicker
}
