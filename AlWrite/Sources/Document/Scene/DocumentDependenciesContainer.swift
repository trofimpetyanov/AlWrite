import Foundation
import UIKit
import PencilKit

@MainActor
final class DocumentDependenciesContainer {
    let drawingStore: ViewStore<DrawingViewState, DrawingViewEvent>
    let viewerStore: ViewStore<ViewerViewState, ViewerViewEvent>

    init(
        drawingStore: ViewStore<DrawingViewState, DrawingViewEvent>,
        viewerStore: ViewStore<ViewerViewState, ViewerViewEvent>
    ) {
        self.drawingStore = drawingStore
        self.viewerStore = viewerStore
    }
}
