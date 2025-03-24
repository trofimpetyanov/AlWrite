import Foundation

@MainActor
protocol HandwritingRecognitionDelegate: AnyObject {
    func handwritingRecognitionDidComplete(text: String, error: Error?)
}