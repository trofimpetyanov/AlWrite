import UIKit
import PencilKit
import Combine

class ViewerViewController: UIViewController {
    
    // MARK: - Properties
    private let viewStore: ViewStore<ViewerState, ViewerEvent>
    private let theView = ViewerView()
    private var observations = Set<AnyCancellable>()
    
    private var currentDrawing: PKDrawing?
    private var isVisible: Bool = false
    
    // MARK: - Initialization
    init(viewStore: ViewStore<ViewerState, ViewerEvent>) {
        self.viewStore = viewStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = theView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(to: viewStore)
        bindToView()
    }
    
    // MARK: - Methods
    func updateCurrentDrawing(_ drawing: PKDrawing) {
        currentDrawing = drawing
    }
    
    func setRecognizedText(_ text: String) {
        viewStore.handle(.recognitionCompleted(.success(text)))
    }
    
    func setRecognitionError(_ error: Error) {
        viewStore.handle(.recognitionCompleted(.failure(error)))
    }
    
    func toggleVisibility() {
        isVisible = !isVisible
        viewStore.handle(.toggleVisibility)
    }
    
    func setVisibility(_ visible: Bool) {
        isVisible = visible
    }
    
    func isViewerVisible() -> Bool {
        return isVisible
    }
    
    // MARK: - Private Methods
    private func bind(to viewStore: ViewStore<ViewerState, ViewerEvent>) {
        viewStore
            .$state
            .removeDuplicates()
            .sink { [weak self] state in
                self?.theView.configure(with: state)
            }
            .store(in: &observations)
    }
    
    private func bindToView() {
        theView.onRecognitionRequested = { [weak self] in
            guard let self = self, let drawing = self.currentDrawing else { 
                return 
            }
            self.viewStore.handle(.recognizeRequested(drawing))
        }
        
        theView.onModeChanged = { [weak self] mode in
            self?.viewStore.handle(.switchRecognitionMode(mode))
        }
    }
} 
