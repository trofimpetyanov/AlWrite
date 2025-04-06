import UIKit

@MainActor
final class DocumentSceneBuilder {
    func build(
        router: DocumentRouting,
        drawingStore: ViewStore<DrawingViewState, DrawingViewEvent>,
        viewerStore: ViewStore<ViewerViewState, ViewerViewEvent>
    ) -> DocumentViewController {
        let store = DocumentStore(
            router: router,
            dependenciesContainer: DocumentDependenciesContainer(
                drawingStore: drawingStore,
                viewerStore: viewerStore
            )
        )

        let viewStore = ViewStore(store)
        
        return DocumentViewController(viewStore: viewStore, router: router)
    }
} 
