import UIKit
import PencilKit

class DocumentViewController: UIDocumentViewController {
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var drawingVC: DrawingViewController = {
        let vc = DrawingViewController()
        vc.drawingChanged = { [weak self] drawing in
            self?.alWriteDocument?.drawing = drawing
            self?.document?.updateChangeCount(.done)
        }
        return vc
    }()
    
    private lazy var sideVC: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .secondarySystemBackground
        return vc
    }()
    
    private var sideVCConstraints: [NSLayoutConstraint] = []
    private var stackAxis: NSLayoutConstraint.Axis = .horizontal
    private var isSideVCHidden = true
    
    private var isToolPickerVisible = true {
        didSet {
            updateToolPickerButton()
            drawingVC.setToolPickerVisible(isToolPickerVisible)
        }
    }
    
    private lazy var viewerButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Viewer",
            image: UIImage(systemName: "text.rectangle.page"),
            primaryAction: UIAction { [weak self] _ in
                self?.toggleViewer()
            },
            menu: createViewerPositionMenu()
        )
        return button
    }()
    
    private lazy var toolPickerButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip.crop.circle.fill"),
            primaryAction: UIAction { [weak self] _ in
                self?.isToolPickerVisible.toggle()
            }
        )
        return button
    }()
    
    private var alWriteDocument: AlWriteDocument? {
        get { document as? AlWriteDocument }
        set { document = newValue }
    }
    
    private var sideVCWidthConstraint: NSLayoutConstraint?
    private var sideVCHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewForCurrentDocument()
        setupViewControllers()
        setupNavigationBar()
        updateViewerButton()
        updateToolPickerButton()
    }

    override func navigationItemDidUpdate() {
        let undoRedoButtons = undoRedoItemGroup.barButtonItems
        navigationItem.rightBarButtonItems = undoRedoButtons
    }
    
    private func setupViewControllers() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        addChild(drawingVC)
        drawingVC.didMove(toParent: self)
        stackView.addArrangedSubview(drawingVC.view)
        
        addChild(sideVC)
        sideVC.didMove(toParent: self)
        stackView.addArrangedSubview(sideVC.view)
        
        sideVCWidthConstraint = sideVC.view.widthAnchor.constraint(equalToConstant: 0)
        sideVCHeightConstraint = sideVC.view.heightAnchor.constraint(equalToConstant: 0)
        
        updateSideVCConstraints(isHidden: true)
    }
    
    private func setupNavigationBar() {
        let centerItemGroups = [
            UIBarButtonItemGroup(
                barButtonItems: [toolPickerButton, viewerButton],
                representativeItem: nil
            )
        ]
        
        navigationItem.centerItemGroups = centerItemGroups
        navigationItem.setRightBarButtonItems(undoRedoItemGroup.barButtonItems, animated: true)
    }
    
    private func createViewerPositionMenu() -> UIMenu {
        UIMenu(title: "", children: [
            UIAction(title: "Right", image: UIImage(systemName: "sidebar.right")) { [weak self] _ in
                self?.updateStackViewAxis(.horizontal, sideVCPosition: .right)
            },
            UIAction(title: "Left", image: UIImage(systemName: "sidebar.left")) { [weak self] _ in
                self?.updateStackViewAxis(.horizontal, sideVCPosition: .left)
            },
            UIAction(title: "Top", image: UIImage(systemName: "sidebar.top")) { [weak self] _ in
                self?.updateStackViewAxis(.vertical, sideVCPosition: .top)
            },
            UIAction(title: "Bottom", image: UIImage(systemName: "sidebar.bottom")) { [weak self] _ in
                self?.updateStackViewAxis(.vertical, sideVCPosition: .bottom)
            }
        ])
    }
    
    private func toggleViewer() {
        isSideVCHidden.toggle()
        updateSideVCConstraints(isHidden: isSideVCHidden)
        updateViewerButton()
    }
    
    private func updateViewerButton() {
        let imageName = isSideVCHidden ? "text.rectangle.page" : "text.rectangle.page.fill"
        viewerButton.image = UIImage(systemName: imageName)
    }
    
    private func updateToolPickerButton() {
        let imageName = isToolPickerVisible ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle"
        toolPickerButton.image = UIImage(systemName: imageName)
    }
    
    private func updateStackViewAxis(_ axis: NSLayoutConstraint.Axis, sideVCPosition: SideVCPosition) {
        stackView.removeArrangedSubview(drawingVC.view)
        stackView.removeArrangedSubview(sideVC.view)
        
        sideVCWidthConstraint?.isActive = false
        sideVCHeightConstraint?.isActive = false
        
        stackView.axis = axis
        stackAxis = axis
        
        switch sideVCPosition {
        case .left, .top:
            stackView.addArrangedSubview(sideVC.view)
            stackView.addArrangedSubview(drawingVC.view)
        case .right, .bottom:
            stackView.addArrangedSubview(drawingVC.view)
            stackView.addArrangedSubview(sideVC.view)
        }
        
        updateSideVCConstraints(isHidden: isSideVCHidden)
    }
    
    private func updateSideVCConstraints(isHidden: Bool) {
        sideVCWidthConstraint?.isActive = false
        sideVCHeightConstraint?.isActive = false
        
        let visibleTop = drawingVC.visibleTopPoint
        let size: CGFloat = isHidden ? 0 : (stackAxis == .horizontal ? view.bounds.width * 0.5 : view.bounds.height * 0.5)
        
        if !isHidden {
            sideVC.view.isHidden = isHidden
        }
        
        if stackAxis == .horizontal {
            sideVCWidthConstraint?.constant = size
            sideVCWidthConstraint?.isActive = true
        } else {
            sideVCHeightConstraint?.constant = size
            sideVCHeightConstraint?.isActive = true
        }
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(transition, forKey: nil)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.stackView.layoutIfNeeded()
        }, completion: { _ in
            if isHidden {
                self.sideVC.view.isHidden = isHidden
            }
            self.drawingVC.maintainVisibleTop(visibleTop, sideViewWidth: size)
        })
    }
    
    override func documentDidOpen() {
        super.documentDidOpen()
        configureViewForCurrentDocument()
    }
    
    private func configureViewForCurrentDocument() {
        guard let alWriteDocument,
              !alWriteDocument.documentState.contains(.closed),
              isViewLoaded
        else { return }
        
        drawingVC.drawing = alWriteDocument.drawing
        drawingVC.setToolPickerVisible(isToolPickerVisible)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawingVC.setToolPickerVisible(isToolPickerVisible)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSideVCConstraints(isHidden: isSideVCHidden)
    }
}

private enum SideVCPosition {
    case left, right, top, bottom
}
