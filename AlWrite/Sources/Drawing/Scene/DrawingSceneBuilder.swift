import Foundation

@MainActor
struct DrawingSceneBuilder {
    func build(
        dependenciesContainer: DrawingDependenciesContainer
    ) -> DrawingViewController {
        DrawingViewController(
            viewStore: ViewStore(
                DrawingStore(
                    dependenciesContainer: dependenciesContainer
                )
            )
        )
    }
}
