import Foundation
import Combine
import PencilKit

@MainActor
final class DocumentStore: Store {
    @Published private(set) var state: DocumentState
    var statePublisher: Published<DocumentState>.Publisher { $state }

    private let router: DocumentRouting
    private let drawingStore: ViewStore<DrawingViewState, DrawingViewEvent>
    private let viewerStore: ViewStore<ViewerViewState, ViewerViewEvent>
    private let dependenciesContainer: DocumentDependenciesContainer
    
    init(router: DocumentRouting, dependenciesContainer: DocumentDependenciesContainer) {
        self.state = DocumentState()
        self.router = router
        self.drawingStore = dependenciesContainer.drawingStore
        self.viewerStore = dependenciesContainer.viewerStore
        self.dependenciesContainer = dependenciesContainer
    }
    
    func handle(_ event: DocumentEvent) {
        switch event {
        case .drawingChanged(let drawing):
            state.drawing = drawing
            drawingStore.handle(.drawingChanged(drawing))
            viewerStore.handle(.drawingUpdated(drawing))
        case .changeViewerPosition(let position):
            state.viewerPosition = position
        case .changeViewerProportion(let proportion):
            state.viewerProportion = proportion
        case .toggleViewer:
            state.isViewerVisible.toggle()
        case .toggleToolPicker:
            state.isToolPickerVisible.toggle()
            drawingStore.handle(.toggleToolPicker(state.isToolPickerVisible))
        }
    }
} 
