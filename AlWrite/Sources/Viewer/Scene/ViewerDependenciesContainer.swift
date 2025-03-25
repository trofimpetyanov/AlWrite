import Foundation

struct ViewerDependenciesContainer {
    let recognitionManager: HandwritingRecognitionManager
    
    init(recognitionManager: HandwritingRecognitionManager) {
        self.recognitionManager = recognitionManager
    }
}
