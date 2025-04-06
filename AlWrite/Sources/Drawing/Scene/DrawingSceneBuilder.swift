import Foundation

@MainActor
struct DrawingSceneBuilder {
    func build() -> DrawingViewController {
        let store = DrawingStore(
            dependenciesContainer: DrawingDependenciesContainer()
        )

        let viewStore = ViewStore(store)
        let viewController = DrawingViewController(viewStore: viewStore)
        
        return viewController
    }
}
