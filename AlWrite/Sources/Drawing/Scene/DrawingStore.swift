import Foundation
import PencilKit

@MainActor
protocol DrawingStoreDelegate: AnyObject {
    func drawingStore(_ store: DrawingStore, didChangeDrawing drawing: PKDrawing)
}

@MainActor
final class DrawingStore: Store {
    @Published private(set) var state: DrawingState
    var statePublisher: Published<DrawingState>.Publisher { $state }

    private let dependenciesContainer: DrawingDependenciesContainer

    weak var delegate: DrawingStoreDelegate?

    init(
        dependenciesContainer: DrawingDependenciesContainer
    ) {
        self.state = DrawingState()
        self.dependenciesContainer = dependenciesContainer
    }

    func handle(_ event: DrawingEvent) {
        switch event {
        case .drawingChanged(let drawing):
            state.drawing = drawing
            delegate?.drawingStore(self, didChangeDrawing: drawing)
        case .toggleToolPicker(let isVisisble):
            state.isToolPickerVisible = isVisisble
        }
    }
}
