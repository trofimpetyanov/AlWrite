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

final class BaseRouter: Routing {
    
    // MARK: - Properties
    private(set) var navigationController: UINavigationController
    
    // MARK: - Initialization
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }
    
    // MARK: - Routing Methods
    func start() {
        let recognitionEngineFactory = RecognitionEngineFactory()
        let context = DocumentRouter.Context(recognitionEngineFactory: recognitionEngineFactory)
        let documentRouter = DocumentRouter(baseRouter: self, context: context)
        documentRouter.showDocumentViewController()
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
    
    func findViewController<T: UIViewController>(byType type: T.Type) -> T? {
        findViewControllerFromMostPresented(byType: type)
    }
    
    func findViewControllerFromMostPresented<T: UIViewController>(byType type: T.Type) -> T? {
        var current = navigationController.presentedViewController
        
        while let presented = current {
            if let found = findInHierarchy(presented, byType: type) {
                return found
            }
            current = presented.presentedViewController
        }
        
        return findInHierarchy(navigationController, byType: type)
    }
    
    private func findInHierarchy<T: UIViewController>(_ viewController: UIViewController, byType type: T.Type) -> T? {
        if let target = viewController as? T {
            return target
        }
        
        if let container = viewController as? UINavigationController {
            for child in container.viewControllers {
                if let found = findInHierarchy(child, byType: type) {
                    return found
                }
            }
        }
        
        for child in viewController.children {
            if let found = findInHierarchy(child, byType: type) {
                return found
            }
        }
        
        return nil
    }
} 
