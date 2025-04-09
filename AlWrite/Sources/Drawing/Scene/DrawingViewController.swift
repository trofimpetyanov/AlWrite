import Combine
import PencilKit
import UIKit

class DrawingViewController: UIViewController {

    // MARK: - Type Aliases
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, DrawingBlock>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DrawingBlock>

    // MARK: - Section Enum
    private enum Section {
        case main
    }

    // MARK: - Properties
    let viewStore: ViewStore<DocumentState, DocumentEvent>
    let toolPicker: PKToolPicker
    private var observations: Set<AnyCancellable> = []
    private weak var activeCanvasView: PKCanvasView?

    private var theView: DrawingCanvasView { view as! DrawingCanvasView }
    private var dataSource: DataSource!

    // MARK: - Lifecycle
    init(viewStore: ViewStore<DocumentState, DocumentEvent>, toolPicker: PKToolPicker) {
        self.viewStore = viewStore
        self.toolPicker = toolPicker
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = DrawingCanvasView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        theView.collectionView.delegate = self
        bind(to: viewStore)
    }

    deinit {
        if let activeCanvas = activeCanvasView {
            toolPicker.removeObserver(activeCanvas)
        }
    }

    // MARK: - Configuration (DataSource setup remains in VC)
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CanvasBlockCell, DrawingBlock> { [weak self] (cell, indexPath, block) in
            guard let self = self else { return }

            cell.configure(with: block)

            cell.drawingDidChange = { [weak self] newDrawing in
                self?.viewStore.handle(.updateBlockDrawing(id: block.id, drawing: newDrawing))
            }
            cell.didTapCell = { [weak self, weak cell] in
                guard let self = self, let tappedCell = cell else { return }
                let newActiveCanvas = tappedCell.canvasView
                tappedCell.makeCanvasFirstResponder()
                self.activeCanvasView = newActiveCanvas
            }

            self.toolPicker.addObserver(cell.canvasView)
        }

        dataSource = DataSource(
            collectionView: theView.collectionView
        ) { (collectionView, indexPath, block) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: block)
        }

        viewStore.$state
            .map(\.isToolPickerVisible)
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] isVisible in
                guard let self = self else { return }
                if !isVisible {
                    if let activeCanvas = self.activeCanvasView {
                        self.toolPicker.setVisible(false, forFirstResponder: activeCanvas)
                    }
                } else {
                    if self.activeCanvasView == nil {
                        if let firstVisibleCell = self.theView.collectionView.visibleCells.first as? CanvasBlockCell {
                            firstVisibleCell.makeCanvasFirstResponder()
                            self.activeCanvasView = firstVisibleCell.canvasView
                        }
                    }
                    if let activeCanvas = self.activeCanvasView {
                        self.toolPicker.setVisible(true, forFirstResponder: activeCanvas)
                    } else {
                        print("Warning: Tried to show ToolPicker but no active canvas found.")
                    }
                }
            }
            .store(in: &observations)
    }

    // MARK: - Bindings
    private func bind(
        to viewStore: ViewStore<DocumentState, DocumentEvent>
    ) {
        viewStore.$state
            .map(\.blocks)
            .removeDuplicates()
            .sink { [weak self] blocks in
                self?.applySnapshot(blocks: blocks)
            }
            .store(in: &observations)
    }

    private func applySnapshot(blocks: [DrawingBlock]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(blocks)
        dataSource.apply(snapshot, animatingDifferences: true)

        updateEmptyState(isEmpty: blocks.isEmpty)
    }

    // MARK: - Empty State Handling
    private func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "pencil.and.scribble")
            config.text = "Нет блоков"
            config.secondaryText = "Добавьте новый блок в верхней панели."
            self.contentUnavailableConfiguration = config
        } else {
            self.contentUnavailableConfiguration = nil
        }
    }

    // MARK: - Public Methods
    func invalidateCollectionViewLayout() {
        theView.collectionView.collectionViewLayout.invalidateLayout()
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - UICollectionViewDelegate
extension DrawingViewController: UICollectionViewDelegate {

    // Context Menu for Deletion
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let block = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { suggestedActions in
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
                 self?.viewStore.handle(.deleteRequested(id: block.id))
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }
}
