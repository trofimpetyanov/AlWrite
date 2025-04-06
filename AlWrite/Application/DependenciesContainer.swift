import SwiftUI

@MainActor
final class DependenciesContainer {
    @Binding var document: AlWriteDocument

    var recognitionEngineFactory: RecognitionEngineFactory

    init(
        document: Binding<AlWriteDocument>,
        recognitionEngineFactory: RecognitionEngineFactory = RecognitionEngineFactory()
    ) {
        self._document = document
        self.recognitionEngineFactory = recognitionEngineFactory
    }
}
