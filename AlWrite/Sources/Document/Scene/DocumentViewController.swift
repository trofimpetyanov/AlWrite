import UIKit
import PencilKit
import Combine
import SwiftUI

class DocumentViewController: UIDocumentViewController {
    
    // MARK: - Properties
    let viewStore: ViewStore<DocumentViewState, DocumentViewEvent>
    
    private let router: DocumentRouting

    private var drawingViewController: UIViewController?
    private var viewerViewController: UIViewController?

    private var toolPickerItem: UIBarButtonItem?
    private var viewerItem: UIBarButtonItem?

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
    init(viewStore: ViewStore<DocumentViewState, DocumentViewEvent>, router: DocumentRouting) {
        self.viewStore = viewStore
        self.router = router
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
        updateToolPickerButton(isVisible: state.isToolPickerVisible)
        updateViewerButton(isVisible: state.isViewerVisible)
        
        if let viewerVC = viewerViewController,
           viewerVC.view.superview != nil,
           viewerVC.view.isHidden != !state.isViewerVisible {
            animateViewerVisibility(isVisible: state.isViewerVisible)
        }

        if alWriteDocument?.drawing != state.drawing {
            alWriteDocument?.drawing = state.drawing
        }
    }
    
    // MARK: - Viewer Animation
    private func animateViewerVisibility(isVisible: Bool) {
        guard let viewerVC = viewerViewController else { return }
        
        let duration: TimeInterval = 0.4

        if isVisible {
            viewerVC.view.isHidden = false
            viewerVC.view.alpha = 0
            
            let offscreenTransform = offscreenTransform(for: viewStore.state.viewerPosition, view: viewerVC.view)
            viewerVC.view.transform = offscreenTransform
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut],
                animations: {
                    viewerVC.view.transform = .identity
                    viewerVC.view.alpha = 1
                    self.view.layoutIfNeeded()
                }
            )
        } else {
            let offscreenTransform = offscreenTransform(for: viewStore.state.viewerPosition, view: viewerVC.view)
            view.layoutIfNeeded()

            let animatingView = UIView(frame: viewerVC.view.frame)
            animatingView.backgroundColor = viewerVC.view.backgroundColor
            viewerVC.view.superview?.addSubview(animatingView)
            viewerVC.view.isHidden = true

            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.4,
                options: [.curveEaseIn],
                animations: {
                    animatingView.transform = offscreenTransform
                    animatingView.alpha = 0
                    self.view.layoutIfNeeded()
                },
                completion: { _ in
                    animatingView.removeFromSuperview()
                    viewerVC.view.transform = .identity
                }
            )
        }
    }

    private func offscreenTransform(for position: DocumentState.ViewerPosition, view: UIView) -> CGAffineTransform {
        switch position {
        case .right:
            return CGAffineTransform(translationX: view.bounds.width, y: 0)
        case .left:
            return CGAffineTransform(translationX: -view.bounds.width, y: 0)
        case .top:
            return CGAffineTransform(translationX: 0, y: -view.bounds.height)
        case .bottom:
            return CGAffineTransform(translationX: 0, y: view.bounds.height)
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

        guard let toolPickerItem = toolPickerItem, 
              let viewerItem = viewerItem
        else { return }

        let itemGroup = UIBarButtonItemGroup(
            barButtonItems: [toolPickerItem, viewerItem],
            representativeItem: nil
        )
        
        navigationItem.centerItemGroups = [itemGroup]
    }
    
    private func setupToolPickerButton() {
        toolPickerItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip.crop.circle"),
            primaryAction: UIAction { [weak self] _ in
                self?.viewStore.handle(.toggleToolPicker)
            }
        )
    }
    
    private func setupViewerButton() {
        viewerItem = UIBarButtonItem(
            image: UIImage(systemName: "text.rectangle.page"),
            primaryAction: UIAction { [weak self] _ in
                self?.viewStore.handle(.toggleViewer)
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

        viewStore.handle(.drawingChanged(alWriteDocument.drawing))
    }
}

extension DocumentViewController: DrawingViewControllerDelegate {
    func drawingViewController(_ viewController: DrawingViewController, didChangeDrawing drawing: PKDrawing) {
        viewStore.handle(.drawingChanged(drawing))
    }
}

