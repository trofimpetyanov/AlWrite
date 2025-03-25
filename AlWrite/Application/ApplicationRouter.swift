import UIKit
import PencilKit

@MainActor
protocol Routing: AnyObject {
    var navigationController: UINavigationController { get }
    
    func start()
    func setRoot(_ viewController: UIViewController, animated: Bool)
    func push(_ viewController: UIViewController, animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
}

final class ApplicationRouter: Routing {
    
    // MARK: - Properties
    private(set) var navigationController: UINavigationController
    private let dependenciesContainer: DependenciesContainer
    
    // MARK: - Initialization
    init(navigationController: UINavigationController = UINavigationController(), 
         dependenciesContainer: DependenciesContainer) {
        self.navigationController = navigationController
        self.dependenciesContainer = dependenciesContainer
    }
    
    // MARK: - Routing Methods
    func start() {
        let documentViewController = dependenciesContainer.makeDocumentViewController(router: self)
        setRoot(documentViewController, animated: false)
    }
    
    func setRoot(_ viewController: UIViewController, animated: Bool) {
        navigationController.setViewControllers([viewController], animated: animated)
    }
    
    func push(_ viewController: UIViewController, animated: Bool) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        navigationController.present(viewController, animated: animated, completion: completion)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        navigationController.dismiss(animated: animated, completion: completion)
    }
    
    func pop(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }
}

// MARK: - DocumentRouting
extension ApplicationRouter: DocumentRouting {
    func showDrawingViewController(delegate: DrawingViewControllerDelegate?) -> DrawingViewController {
        let drawingViewController = dependenciesContainer.makeDrawingViewController()
        drawingViewController.delegate = delegate
        return drawingViewController
    }
    
    func showViewerViewController(drawing: PKDrawing) -> ViewerViewController {
        let viewerViewController = dependenciesContainer.makeViewerViewController()
        viewerViewController.updateCurrentDrawing(drawing)
        return viewerViewController
    }
} 
