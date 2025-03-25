import UIKit
import PencilKit

protocol DocumentRouting: Routing {
    func showDrawingViewController(delegate: DrawingViewControllerDelegate?) -> DrawingViewController
    func showViewerViewController(drawing: PKDrawing) -> ViewerViewController
} 
