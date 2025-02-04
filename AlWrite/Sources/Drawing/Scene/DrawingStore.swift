import Foundation
import PencilKit

@MainActor
final class DrawingStore: Store {
    @Published private(set) var state: DrawingState
    var statePublisher: Published<DrawingState>.Publisher { $state }

    private let dependenciesContainer: DrawingDependenciesContainer

    init(
        dependenciesContainer: DrawingDependenciesContainer
    ) {
        self.state = DrawingState()
        self.dependenciesContainer = dependenciesContainer
    }

    func handle(_ event: DrawingEvent) {
        switch event {
        case .updateDrawing(let drawing):
            state.drawing = drawing ?? PKDrawing()
            
        case .toggleToolPicker:
            state.isToolPickerVisible.toggle()
        }
    }
}
