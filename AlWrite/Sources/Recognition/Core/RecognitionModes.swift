import Foundation
import MyScriptInteractiveInk_Runtime

enum StandardRecognitionMode: RecognitionMode, CaseIterable {
    case text
    case math
    
    var partType: String {
        switch self {
        case .text: "Text"
        case .math: "Math"
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