import UIKit
import SwiftUI
import PencilKit

@MainActor
final class DocumentSceneBuilder {

    func build(router: DocumentRouting) -> DocumentViewController {
        
        let recognitionManager = HandwritingRecognitionManager()
        
        let dependenciesContainer = DocumentDependenciesContainer(
            recognitionManager: recognitionManager
        )
        
        let store = DocumentStore(
            router: router,
            dependenciesContainer: dependenciesContainer,
            document: nil
        )
        
        let viewStore = ViewStore<DocumentState, DocumentEvent>(store)

        let sharedToolPicker = PKToolPicker()

        let drawingViewController = DrawingSceneBuilder().build(viewStore: viewStore, toolPicker: sharedToolPicker)
        let viewerViewController = ViewerSceneBuilder().build(viewStore: viewStore)

        let documentViewController = DocumentViewController(viewStore: viewStore, router: router, toolPicker: sharedToolPicker)

        documentViewController.setDrawingViewController(drawingViewController)
        documentViewController.setViewerViewController(viewerViewController)

        return documentViewController
    }
}