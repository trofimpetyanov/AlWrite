import UIKit
import PencilKit
import Combine
import SwiftUI

class DocumentViewController: UIDocumentViewController {
    
    // MARK: - Properties

    let viewStore: ViewStore<DocumentState, DocumentEvent>
    
    private let router: DocumentRouting
    let toolPicker: PKToolPicker

    private var drawingViewController: UIViewController?
    private var viewerViewController: UIViewController?

    private var toolPickerItem: UIBarButtonItem?
    private var viewerItem: UIBarButtonItem?

    private var addTextBlockItem: UIBarButtonItem?
    private var addMathBlockItem: UIBarButtonItem?

    private var observations: Set<AnyCancellable> = []

    private var alWriteDocument: AlWriteDocument? {
        get { document as? AlWriteDocument }
        set { document = newValue }
    }

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Initialization

    init(viewStore: ViewStore<DocumentState, DocumentEvent>, router: DocumentRouting, toolPicker: PKToolPicker) {
        self.viewStore = viewStore
        self.router = router
        self.toolPicker = toolPicker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContentStackView()
        setupNavigationBar()
        bindToViewStore()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { [weak self] _ in
            self?.contentStackView.layoutIfNeeded()
        }
    }
    
    override func documentDidOpen() {
        super.documentDidOpen()
        
        if let doc = alWriteDocument {
            viewStore.handle(.setDocument(doc))
        }
        
        configureViewForCurrentDocument()
    }

    // MARK: - Bindings

    private func bindToViewStore() {
        viewStore.$state
            .removeDuplicates()
            .sink { [weak self] state in
                self?.update(for: state)
            }
            .store(in: &observations)
    }

    private func update(for state: DocumentState) {
        toolPickerItem?.isEnabled = !state.blocks.isEmpty

        updateToolPickerButton(isVisible: state.isToolPickerVisible)
        updateViewerButton(isVisible: state.isViewerVisible)

        if let viewerVC = viewerViewController,
           viewerVC.view.superview != nil,
           viewerVC.view.isHidden != !state.isViewerVisible {
            updateViewerVisibility(isVisible: state.isViewerVisible)
        }
    }
    
    // MARK: - Viewer Visibility

    private func updateViewerVisibility(isVisible: Bool) {
        guard let viewerVC = viewerViewController else { return }

        UIView.animate(withDuration: 0.3) {
            viewerVC.view.isHidden = !isVisible
            self.view.layoutIfNeeded()
            if let drawingVC = self.drawingViewController as? DrawingViewController {
                drawingVC.invalidateCollectionViewLayout()
            }
        }
    }
    
    // MARK: - Setup
    func setDrawingViewController(_ viewController: UIViewController) {
        addChild(viewController)
        contentStackView.addArrangedSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.didMove(toParent: self)

        self.drawingViewController = viewController
    }

    func setViewerViewController(_ viewController: UIViewController) {
        addChild(viewController)
        contentStackView.addArrangedSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.didMove(toParent: self)

        self.viewerViewController = viewController
        viewController.view.isHidden = !viewStore.state.isViewerVisible
    }
    
    private func setupContentStackView() {
        view.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupNavigationBar() {
        let appearance = navigationController?.navigationBar.standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        setupToolPickerButton()
        setupViewerButton()
        navigationItem.rightBarButtonItems = [viewerItem, toolPickerItem].compactMap { $0 }

        setupAddBlockButtons()
        guard let addTextBlockItem = addTextBlockItem, let addMathBlockItem = addMathBlockItem else { return }
        let centerGroup = UIBarButtonItemGroup(
            barButtonItems: [addTextBlockItem, addMathBlockItem],
            representativeItem: nil
        )
        navigationItem.centerItemGroups = [centerGroup]
    }
    
    private func setupToolPickerButton() {
        toolPickerItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip.crop.circle"),
            primaryAction: UIAction { [weak self] _ in
                self?.viewStore.handle(.toggleToolPicker)
            }
        )
        updateToolPickerButton(isVisible: viewStore.state.isToolPickerVisible)
    }
    
    private func setupViewerButton() {
        viewerItem = UIBarButtonItem(
            image: UIImage(systemName: "text.rectangle.page"),
            primaryAction: UIAction { [weak self] _ in
                self?.viewStore.handle(.toggleViewer)
            }
        )
    }
    
    private func setupAddBlockButtons() {
        addTextBlockItem = UIBarButtonItem(
            image: UIImage(systemName: "textformat"),
            primaryAction: UIAction { [weak self] _ in
                self?.viewStore.handle(.addBlock(type: .text))
            }
        )
        addMathBlockItem = UIBarButtonItem(
            image: UIImage(systemName: "function"),
            primaryAction: UIAction { [weak self] _ in
                self?.viewStore.handle(.addBlock(type: .math))
            }
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
    
    private func configureViewForCurrentDocument() {
        guard let alWriteDocument,
              !alWriteDocument.documentState.contains(.closed),
              isViewLoaded
        else { return }

        viewStore.handle(.documentLoaded(blocks: alWriteDocument.blocks))
    }
}

