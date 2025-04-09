import UIKit
import SwiftUI
import PencilKit

@MainActor
struct ViewerSceneBuilder {
    func build(viewStore: ViewStore<DocumentState, DocumentEvent>) -> UIViewController {
        return UIHostingController(rootView: ViewerView(viewStore: viewStore))
    }
} 