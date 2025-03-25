import UIKit
import PencilKit

@MainActor
 final class DependenciesContainer {
    private lazy var recognitionEngineFactory: RecognitionEngineFactory = {
        RecognitionEngineFactory()
    }()
    
    // MARK: - Document
    func makeDocumentViewController(router: Routing) -> DocumentViewController {
        let documentViewController = DocumentViewController()
        documentViewController.router = router
        return documentViewController
    }
    
    // MARK: - Drawing
    func makeDrawingViewController() -> DrawingViewController {
        let drawingViewController = DrawingSceneBuilder().build(
            dependenciesContainer: DrawingDependenciesContainer(
                engineFactory: recognitionEngineFactory
            )
        )
        
        return drawingViewController
    }
    
    // MARK: - Viewer
    func makeViewerViewController() -> ViewerViewController {
        let viewerViewController = ViewerSceneBuilder().build(
            dependenciesContainer: ViewerDependenciesContainer(
                recognitionManager: HandwritingRecognitionManager(
                    engineFactory: recognitionEngineFactory
                )
            )
        )
        
        return viewerViewController
    }
} 
