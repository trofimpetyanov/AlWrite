import Foundation

struct ViewerDependenciesContainer {
    let recognitionManager: HandwritingRecognizer

    init(recognitionManager: HandwritingRecognizer) {
        self.recognitionManager = recognitionManager
    }
}
