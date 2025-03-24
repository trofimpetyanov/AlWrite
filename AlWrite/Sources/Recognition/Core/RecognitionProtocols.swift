import Foundation
import PencilKit

enum RecognitionError: Error {
    case engineNotInitialized
    case noSupportedMimeTypes
    case invalidMimeType
    case exportFailed(underlyingError: Error)
    case noStrokesToRecognize
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

protocol RecognitionDelegate: AnyObject {
    func recognitionDidComplete(result: Result<String, Error>)
}