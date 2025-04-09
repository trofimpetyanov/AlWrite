import UIKit
import PencilKit

@MainActor
struct DrawingSceneBuilder {
    func build(viewStore: ViewStore<DocumentState, DocumentEvent>, toolPicker: PKToolPicker) -> DrawingViewController {
        return DrawingViewController(viewStore: viewStore, toolPicker: toolPicker)
    }
}
