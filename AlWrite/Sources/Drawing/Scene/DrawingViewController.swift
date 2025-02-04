import Combine
import PencilKit
import UIKit

protocol DrawingViewControllerDelegate: AnyObject {
    func drawingViewController(
        _ viewController: DrawingViewController,
        didUpdateDrawing drawing: PKDrawing
    )
    
    func drawingViewController(
        _ viewController: DrawingViewController,
        didToggleToolPicker isVisible: Bool
    )
}

class DrawingViewController: UIViewController {

    // MARK: - Properties
    private var viewStore: ViewStore<DrawingViewState, DrawingViewEvent>
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
    
    // MARK: - Methods
    func toggleToolPicker() {
        viewStore.handle(.toggleToolPicker)
    }
    
    func updateDrawing(_ drawing: PKDrawing?) {
        viewStore.handle(.updateDrawing(drawing))
    }

    // MARK: Bindings
    private func bind(
        to viewStore: ViewStore<DrawingViewState, DrawingViewEvent>
    ) {
        viewStore
            .$state
            .removeDuplicates()
            .sink { [weak self] state in
                self?.theView.configure(with: state)
                self?.delegate?.drawingViewController(
                    self!, 
                    didToggleToolPicker: state.isToolPickerVisible
                )
            }
            .store(in: &observations)
    }

    private func bindToView() {
        theView.onUpdateDrawing = { [weak self] drawing in
            guard let self = self else { return }
            self.delegate?.drawingViewController(self, didUpdateDrawing: drawing)
        }
    }
}
