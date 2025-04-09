import Foundation
import PencilKit

enum RecognitionError: Error, Equatable {
    case engineNotInitialized
    case noSupportedMimeTypes
    case invalidMimeType
    case exportFailed(underlyingError: Error)
    case noStrokesToRecognize

    static func == (lhs: RecognitionError, rhs: RecognitionError) -> Bool {
        switch (lhs, rhs) {
        case (.engineNotInitialized, .engineNotInitialized),
            (.noSupportedMimeTypes, .noSupportedMimeTypes),
            (.invalidMimeType, .invalidMimeType),
            (.noStrokesToRecognize, .noStrokesToRecognize):
            return true
        case (.exportFailed(let lhsError), .exportFailed(let rhsError)):
            return lhsError as NSError == rhsError as NSError
        default:
            return false
        }
    }
}

protocol RecognitionMode {
    var partType: String { get }
    var mimeType: Any { get }
    var mimeTypeString: String { get }
    var description: String { get }
}

protocol RecognitionService {
    func processDrawing(_ drawing: PKDrawing) async throws -> String
    func clear()
}

protocol RecognitionEngine {
    var currentMode: RecognitionMode { get }
    func setMode(_ mode: RecognitionMode)
    func createRecognizer() -> RecognitionService
}
