import UIKit
import PencilKit

class CanvasBlockCell: UICollectionViewCell {

    static let reuseIdentifier = "canvasBlockCell"

    var drawingDidChange: ((PKDrawing) -> Void)?
    var didTapCell: (() -> Void)?

    private let standardPageWidth: CGFloat = 595.2
    private let desiredAspectRatio: CGFloat = 0.25

    lazy var canvasView: PKCanvasView = {
        let canvas = PKCanvasView()
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.delegate = self
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.isScrollEnabled = false
        canvas.minimumZoomScale = 0.1
        canvas.maximumZoomScale = 4.0
        canvas.zoomScale = 1.0
        return canvas
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateZoomScale()
    }

    private func setupViews() {
        contentView.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: contentView.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
    }

    func configure(with block: DrawingBlock) {
        if canvasView.drawing != block.drawing {
            canvasView.drawing = block.drawing
        }
        updateZoomScale()
    }

    func makeCanvasFirstResponder() {
        canvasView.becomeFirstResponder()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        drawingDidChange = nil
        didTapCell = nil
        canvasView.drawing = PKDrawing()
    }

    // MARK: - Self Sizing
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetWidth = layoutAttributes.size.width
        let calculatedHeight = targetWidth * desiredAspectRatio
        let newAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        newAttributes.frame.size = CGSize(width: max(targetWidth, 1), height: calculatedHeight)
        return newAttributes
    }

    // MARK: - Private Helpers
    private func updateZoomScale() {
        guard bounds.width > 0, standardPageWidth > 0 else { return }
        let scale = bounds.width / standardPageWidth
        guard scale > 0, scale.isFinite else { return }

        if abs(canvasView.minimumZoomScale - scale) > 0.001 {
            canvasView.minimumZoomScale = scale
        }
        let maxScale = scale * 4
        if abs(canvasView.maximumZoomScale - maxScale) > 0.001 {
             canvasView.maximumZoomScale = maxScale
        }
        if abs(canvasView.zoomScale - scale) > 0.001 {
             canvasView.zoomScale = scale
        }
        canvasView.setContentOffset(.zero, animated: false)
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        didTapCell?()
    }
}

extension CanvasBlockCell: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        drawingDidChange?(canvasView.drawing)
    }
}
