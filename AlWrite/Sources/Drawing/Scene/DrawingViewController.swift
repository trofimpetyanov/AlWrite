import Combine
import PencilKit
import UIKit

@MainActor
protocol DrawingViewControllerDelegate: AnyObject {
    func drawingViewController(
        _ viewController: DrawingViewController,
        didChangeDrawing drawing: PKDrawing
    )
}

class DrawingViewController: UIViewController {

    // MARK: - Properties
    let viewStore: ViewStore<DrawingViewState, DrawingViewEvent>

    private var theView: DrawingView { view as! DrawingView }
    private var observations: Set<AnyCancellable> = []

    weak var delegate: DrawingViewControllerDelegate?

    // MARK: - Lifecycle
    init(viewStore: ViewStore<DrawingViewState, DrawingViewEvent>) {
        self.viewStore = viewStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = DrawingView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(to: viewStore)
        bindToView()
    }

    // MARK: - Bindings
    private func bind(
        to viewStore: ViewStore<DrawingViewState, DrawingViewEvent>
    ) {
        viewStore.$state
            .removeDuplicates()
            .sink { [weak self] state in
                self?.theView.configure(with: state)
            }
            .store(in: &observations)
    }

    private func bindToView() {
        theView.onUpdateDrawing = { [weak self] drawing in
            guard let self,
                  self.viewStore.state.drawing != drawing
            else { return }
            
            self.viewStore.handle(.drawingChanged(drawing))
            self.delegate?.drawingViewController(self, didChangeDrawing: drawing)
        }
    }
}
