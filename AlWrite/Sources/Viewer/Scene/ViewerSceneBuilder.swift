import UIKit

@MainActor
struct ViewerSceneBuilder {
    func build(dependenciesContainer: ViewerDependenciesContainer) -> ViewerViewController {
        let store = ViewerStore(dependenciesContainer: dependenciesContainer)
        dependenciesContainer.recognitionManager.delegate = store
        
        let viewStore = ViewStore(store)
        let viewController = ViewerViewController(viewStore: viewStore)
        
        return viewController
    }
} 
