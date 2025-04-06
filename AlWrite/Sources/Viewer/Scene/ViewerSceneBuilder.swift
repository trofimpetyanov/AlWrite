import UIKit
import SwiftUI

@MainActor
struct ViewerSceneBuilder {
    func build(
        context: DocumentRouter.Context
    ) -> UIHostingController<ViewerView> {
        let recognitionManager = HandwritingRecognitionManager(
            engineFactory: context.recognitionEngineFactory
        )

        let dependenciesContainer = ViewerDependenciesContainer(
            recognitionManager: recognitionManager
        )

        let store = ViewerStore(dependenciesContainer: dependenciesContainer)
        let viewStore = ViewStore(store)
        recognitionManager.delegate = store

        let view = ViewerView(viewStore: viewStore)
        let viewController = UIHostingController(rootView: view)

        return viewController
    }
}
