import Foundation

@MainActor
struct DrawingSceneBuilder {
    func build(
        dependenciesContainer: DrawingDependenciesContainer
    ) -> DrawingViewController {
        let store = DrawingStore(
            dependenciesContainer: dependenciesContainer
        )
        let viewStore = ViewStore(store)
        let viewController = DrawingViewController(viewStore: viewStore)

        store.delegate = viewController
        
        return viewController
    }
}
