import Foundation
import MyScriptInteractiveInk_Runtime

enum StandardRecognitionMode: RecognitionMode {
    case text
    case math
    
    var partType: String {
        switch self {
        case .text:
            return "Text"
        case .math:
            return "Math"
        }
    }
    
    var mimeType: Any {
        switch self {
        case .text:
            return IINKMimeType.text
        case .math:
            return IINKMimeType.laTeX
        }
    }
    
    var mimeTypeString: String {
        switch self {
        case .text:
            return "text/plain"
        case .math:
            return "application/x-latex"
        }
    }
    
    var description: String {
        switch self {
        case .text:
            return "Text Recognition"
        case .math:
            return "Math Recognition"
        }
    }
} 