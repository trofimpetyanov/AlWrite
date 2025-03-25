import UIKit
import PencilKit

class DocumentViewController: UIDocumentViewController {
    
    // MARK: - Properties
    private var drawingViewController: DrawingViewController?
    private var viewerViewController: ViewerViewController?
    
    private var toolPickerItem: UIBarButtonItem?
    private var viewerItem: UIBarButtonItem?
    
    private var isViewerVisible: Bool = false
    private var contentStackView: UIStackView!
    
    var router: Routing?
    
    private var alWriteDocument: AlWriteDocument? {
        get { document as? AlWriteDocument }
        set { document = newValue }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentStackView()
        setupDrawingViewController()
        setupViewerViewController()
        setupNavigationItems()
        configureViewForCurrentDocument()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { [weak self] _ in
            self?.updateViewsVisibility()
        }
    }
    
    override func documentDidOpen() {
        super.documentDidOpen()
        
        configureViewForCurrentDocument()
    }
    
    // MARK: - Setup
    private func setupContentStackView() {
        contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 0
        
        view.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupDrawingViewController() {
        guard let router = router as? DocumentRouting else { return }
        
        let drawingViewController = router.showDrawingViewController(delegate: self)
        addChild(drawingViewController)
        contentStackView.addArrangedSubview(drawingViewController.view)
        drawingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        drawingViewController.didMove(toParent: self)
        self.drawingViewController = drawingViewController
    }
    
    private func setupViewerViewController() {
        guard let router = router as? DocumentRouting,
              let drawing = drawingViewController?.getCurrentDrawing() else { return }
        
        let viewerViewController = router.showViewerViewController(drawing: drawing)
        
        addChild(viewerViewController)
        contentStackView.addArrangedSubview(viewerViewController.view)
        viewerViewController.view.translatesAutoresizingMaskIntoConstraints = false

        let viewerWidth = UIDevice.current.userInterfaceIdiom == .pad ? 0.3 : 0.5
        viewerViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: viewerWidth).isActive = true
        viewerViewController.view.isHidden = true
        
        viewerViewController.didMove(toParent: self)
        self.viewerViewController = viewerViewController
    }
    
    private func setupNavigationItems() {
        setupToolPickerButton()
        setupViewerButton()

        guard let toolPickerItem = toolPickerItem, 
              let viewerItem = viewerItem else {
            return
        }

        let itemGroup = UIBarButtonItemGroup(
            barButtonItems: [toolPickerItem, viewerItem],
            representativeItem: nil
        )
        
        navigationItem.centerItemGroups = [itemGroup]

        navigationItem.leftBarButtonItems = nil
        navigationItem.rightBarButtonItems = nil
    }
    
    private func setupToolPickerButton() {
        toolPickerItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip.crop.circle"),
            primaryAction: UIAction { [weak self] _ in
                self?.drawingViewController?.toggleToolPicker()
            }
        )
    }
    
    private func setupViewerButton() {
        let action = UIAction { [weak self] _ in
            self?.toggleViewer()
        }
        
        viewerItem = UIBarButtonItem(
            image: UIImage(systemName: "text.rectangle.page"),
            primaryAction: action
        )
    }
    
    private func updateToolPickerButton(isVisible: Bool) {
        let imageName = isVisible ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle"
        toolPickerItem?.image = UIImage(systemName: imageName)
    }
    
    private func updateViewerButton(isVisible: Bool) {
        let imageName = isVisible ? "text.rectangle.page.fill" : "text.rectangle.page"
        viewerItem?.image = UIImage(systemName: imageName)
    }
    
    private func toggleViewer() {
        isViewerVisible.toggle()
        
        guard let viewerVC = viewerViewController else { return }
        viewerVC.setVisibility(isViewerVisible)
        
        updateViewsVisibility()
        updateViewerButton(isVisible: isViewerVisible)

        if isViewerVisible, let drawing = drawingViewController?.getCurrentDrawing() {
            viewerViewController?.updateCurrentDrawing(drawing)
        }
    }
    
    private func updateViewsVisibility() {
        guard let viewerVC = viewerViewController else { return }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut],
            animations: {
                viewerVC.view.isHidden = !self.isViewerVisible
                self.contentStackView.layoutIfNeeded()
            }
        )
    }
    
    private func configureViewForCurrentDocument() {
        guard let alWriteDocument,
              !alWriteDocument.documentState.contains(.closed),
              isViewLoaded
        else { return }
        
        drawingViewController?.updateDrawing(alWriteDocument.drawing)
        
        if isViewerVisible, let drawing = alWriteDocument.drawing {
            viewerViewController?.updateCurrentDrawing(drawing)
        }
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
        
        if isViewerVisible {
            viewerViewController?.updateCurrentDrawing(drawing)
        }
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
        if isViewerVisible {
            viewerViewController?.setRecognizedText(text)
        }
    }
}
