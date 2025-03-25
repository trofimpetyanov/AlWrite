import Combine
import PencilKit
import UIKit
import MyScriptInteractiveInk_Runtime

protocol DrawingViewControllerDelegate: AnyObject {
    func drawingViewController(
        _ viewController: DrawingViewController,
        didUpdateDrawing drawing: PKDrawing
    )
    
    func drawingViewController(
        _ viewController: DrawingViewController,
        didToggleToolPicker isVisible: Bool
    )
    
    func drawingViewController(
        _ viewController: DrawingViewController,
        didRecognizeText text: String
    )
}

class DrawingViewController: UIViewController {

    // MARK: - Properties
    private var viewStore: ViewStore<DrawingViewState, DrawingViewEvent>
    private var theView: DrawingView { view as! DrawingView }
    private var observations: Set<AnyCancellable> = []
    
    weak var delegate: DrawingViewControllerDelegate?
    
    private lazy var recognizeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Распознать", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(recognizeHandwriting), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Очистить", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(clearDrawing), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var toggleModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Режим: Текст", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(toggleRecognitionMode), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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
        
        setupButtons()
        bind(to: viewStore)
        bindToView()
    }
    
    private func setupButtons() {
        view.addSubview(recognizeButton)
        view.addSubview(clearButton)
        view.addSubview(toggleModeButton)
        
        NSLayoutConstraint.activate([
            recognizeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recognizeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            recognizeButton.widthAnchor.constraint(equalToConstant: 120),
            recognizeButton.heightAnchor.constraint(equalToConstant: 44),
            
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clearButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            clearButton.widthAnchor.constraint(equalToConstant: 120),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            
            toggleModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toggleModeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            toggleModeButton.widthAnchor.constraint(equalToConstant: 120),
            toggleModeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Methods
    func toggleToolPicker() {
        viewStore.handle(.toggleToolPicker)
    }
    
    func updateDrawing(_ drawing: PKDrawing?) {
        viewStore.handle(.updateDrawing(drawing))
    }
    
    @objc private func recognizeHandwriting() {
        let drawing = viewStore.state.drawing
        let directCanvasDrawing = theView.getDirectCanvasDrawing()
        
        let finalDrawing = drawing.strokes.count >= directCanvasDrawing.strokes.count ? drawing : directCanvasDrawing
        
        if directCanvasDrawing.strokes.count > 0 && drawing.strokes.isEmpty {
            self.viewStore.handle(.updateDrawing(directCanvasDrawing))
        }
        
        if finalDrawing.strokes.isEmpty {
            let alertController = UIAlertController(
                title: "Пустой рисунок",
                message: "Нарисуйте что-нибудь перед распознаванием",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default
            ))
            
            present(alertController, animated: true)
            return
        }
        
        viewStore.handle(.recognizeDrawing(finalDrawing))
    }
    
    @objc private func clearDrawing() {
        viewStore.handle(.clearDrawing)
    }

    @objc private func toggleRecognitionMode() {
        let currentMode = viewStore.state.recognitionMode
        
        let newMode: StandardRecognitionMode = (currentMode == .text) ? .math : .text
        
        viewStore.handle(.switchRecognitionMode(newMode))
        
        toggleModeButton.setTitle("Режим: \(newMode == .text ? "Текст" : "Математика")", for: .normal)
        
        toggleModeButton.backgroundColor = (newMode == .text) ? .systemGray : .systemPurple
    }

    // MARK: - Bindings
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
            
            self.viewStore.handle(.updateDrawing(drawing))
            
            self.delegate?.drawingViewController(self, didUpdateDrawing: drawing)
        }
    }
}

// MARK: - DrawingStoreDelegate
extension DrawingViewController: DrawingStoreDelegate {
    func didCompleteRecognition(result: Result<String, Error>) {
        switch result {
        case .success(let text):
            let currentMode = viewStore.state.recognitionMode
            
            var title = "Распознанный текст"
            var message = text
            
            if currentMode == .math {
                title = "Формула (LaTeX)"
                
                if !text.isEmpty && !text.hasPrefix("$") {
                    if !text.hasPrefix("\\") && !text.hasPrefix("$") {
                        message = "$$" + text + "$$"
                    }
                }
            }
            
            let alertController = UIAlertController(
                title: title,
                message: text.isEmpty ? "Текст не распознан" : message,
                preferredStyle: .alert
            )
            
            if !text.isEmpty {
                alertController.addAction(UIAlertAction(
                    title: "Копировать",
                    style: .default,
                    handler: { _ in
                        UIPasteboard.general.string = message
                    }
                ))
            }
            
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default
            ))
            
            present(alertController, animated: true)
            
            delegate?.drawingViewController(self, didRecognizeText: text)
            
        case .failure(let error):
            let alertController = UIAlertController(
                title: "Ошибка распознавания",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(
                title: "OK",
                style: .default
            ))
            
            present(alertController, animated: true)
        }
    }
}
