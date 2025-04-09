import Foundation
import UIKit
import PencilKit

@MainActor
class DocumentDependenciesContainer {
    let recognitionManager: HandwritingRecognizer

    init(
        recognitionManager: HandwritingRecognizer
    ) {
        self.recognitionManager = recognitionManager
    }
}
