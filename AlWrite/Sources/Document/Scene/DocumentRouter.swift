import SwiftUI
import PencilKit

@MainActor
protocol DocumentRouting: AnyObject {
    func showDocumentViewController()
}

@MainActor
final class DocumentRouter {
    private let baseRouter: BaseRouter
    private let context: Context
    
    private var isDocumentViewPresented: Bool {
        baseRouter.findViewControllerFromMostPresented(byType: DocumentViewController.self) != nil
    }
    
    init(baseRouter: BaseRouter, context: Context) {
        self.baseRouter = baseRouter
        self.context = context
    }
    
    private var documentViewController: DocumentViewController? {
        baseRouter.findViewControllerFromMostPresented(byType: DocumentViewController.self)
    }
    
    private var viewerViewController: UIHostingController<ViewerView>? {
        guard let docVC = documentViewController else { return nil }
        return docVC.children.first { $0 is UIHostingController<ViewerView> } as? UIHostingController<ViewerView>
    }
}

// MARK: - DocumentRouting
extension DocumentRouter: DocumentRouting {
    func showDocumentViewController() {
        guard !isDocumentViewPresented else {
            return
        }

        let documentViewController = DocumentSceneBuilder().build(router: self)

        baseRouter.setRoot(documentViewController, animated: false)
    }
}

// MARK: - Context
extension DocumentRouter {
    struct Context {
        let recognitionEngineFactory: RecognitionEngineFactory
    }
} 
