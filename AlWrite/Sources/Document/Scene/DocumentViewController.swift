import UIKit
import PencilKit

class DocumentViewController: UIDocumentViewController {
    
    // MARK: - Properties
    private var drawingViewController: DrawingViewController?
    private var toolPickerItem: UIBarButtonItem?
    
    private var alWriteDocument: AlWriteDocument? {
        get { document as? AlWriteDocument }
        set { document = newValue }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDrawingViewController()
        configureViewForCurrentDocument()
    }
    
    override func documentDidOpen() {
        super.documentDidOpen()
        
        configureViewForCurrentDocument()
    }
    
    // MARK: - Setup
    private func setupDrawingViewController() {
        let dependenciesContainer = DrawingDependenciesContainer(engineFactory: RecognitionEngineFactory())
        let drawingViewController = DrawingSceneBuilder().build(
            dependenciesContainer: dependenciesContainer
        )
        
        addChild(drawingViewController)
        view.addSubview(drawingViewController.view)
        drawingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            drawingViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            drawingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            drawingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            drawingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        drawingViewController.didMove(toParent: self)
        drawingViewController.delegate = self
        
        self.drawingViewController = drawingViewController
        setupToolPickerButton()
    }
    
    private func setupToolPickerButton() {
        toolPickerItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip.crop.circle"),
            primaryAction: UIAction { [weak self] _ in
                self?.drawingViewController?.toggleToolPicker()
            }
        )
        
        let itemGroup = UIBarButtonItemGroup(
            barButtonItems: [toolPickerItem!],
            representativeItem: nil
        )
        navigationItem.centerItemGroups = [itemGroup]
    }
    
    private func updateToolPickerButton(isVisible: Bool) {
        let imageName = isVisible ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle"
        toolPickerItem?.image = UIImage(systemName: imageName)
    }
    
    private func configureViewForCurrentDocument() {
        guard let alWriteDocument,
              !alWriteDocument.documentState.contains(.closed),
              isViewLoaded
        else { return }
        
        drawingViewController?.updateDrawing(alWriteDocument.drawing)
    }
}

// MARK: - DrawingViewControllerDelegate
extension DocumentViewController: DrawingViewControllerDelegate {
    func drawingViewController(
        _ viewController: DrawingViewController,
        didUpdateDrawing drawing: PKDrawing
    ) {
        alWriteDocument?.drawing = drawing
        document?.updateChangeCount(.done)
    }
    
    func drawingViewController(
        _ viewController: DrawingViewController,
        didToggleToolPicker isVisible: Bool
    ) {
        updateToolPickerButton(isVisible: isVisible)
    }
    
    func drawingViewController(
        _ viewController: DrawingViewController,
        didRecognizeText text: String
    ) {
        let alertController = UIAlertController(
            title: "Распознанный текст",
            message: text,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(
            title: "Копировать",
            style: .default,
            handler: { _ in
                UIPasteboard.general.string = text
            }
        ))
        
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        ))
        
        present(alertController, animated: true)
    }
}
