import PencilKit
import UIKit

class DrawingView: UIView {

    // MARK: - Properties
    var onUpdateDrawing: ((PKDrawing) -> Void)?

    private let standardPageWidth: CGFloat = 595.2
    private let standardPageHeight: CGFloat = 841.8

    // MARK: UI Components
    private lazy var canvasView: PKCanvasView = {
        let canvas = PKCanvasView()
        canvas.delegate = self
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.alwaysBounceVertical = true
        return canvas
    }()

    private lazy var toolPicker: PKToolPicker = {
        let picker = PKToolPicker()
        picker.addObserver(canvasView)
        picker.addObserver(self)
        return picker
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCanvas()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCanvasScale()
    }

    // MARK: - Methods
    // MARK: Configure
    func configure(with state: DrawingState) {
        setToolPickerVisible(state.isToolPickerVisible)
        canvasView.drawing = state.drawing
    }

    func setDrawing(_ drawing: PKDrawing) {
        canvasView.drawing = drawing
    }

    func getDirectCanvasDrawing() -> PKDrawing {
        return canvasView.drawing
    }

    // MARK: Private Methods
    private func setupCanvas() {
        addSubview(canvasView)

        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
    }

    private func updateCanvasScale() {
        let scale = bounds.width / standardPageWidth
        canvasView.minimumZoomScale = scale
        canvasView.maximumZoomScale = scale * 5
        canvasView.zoomScale = scale
        
        updateContentSizeForDrawing()
    }

    private func updateContentSizeForDrawing() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat

        if !drawing.bounds.isNull {
            contentHeight = max(
                standardPageHeight * canvasView.zoomScale,
                (drawing.bounds.maxY + 500) * canvasView.zoomScale
            )
        } else {
            contentHeight = standardPageHeight * canvasView.zoomScale
        }

        canvasView.contentSize = CGSize(
            width: standardPageWidth * canvasView.zoomScale,
            height: contentHeight
        )
    }

    func setToolPickerVisible(_ visible: Bool) {
        if visible {
            canvasView.becomeFirstResponder()
            toolPicker.setVisible(true, forFirstResponder: canvasView)
        } else {
            toolPicker.setVisible(false, forFirstResponder: canvasView)
            canvasView.resignFirstResponder()
        }
    }
}

// MARK: - PKCanvasViewDelegate
extension DrawingView: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
        onUpdateDrawing?(canvasView.drawing)
    }
}

// MARK: - PKToolPickerObserver
extension DrawingView: PKToolPickerObserver {
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }

    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }

    private func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: self)

        if !obscuredFrame.isNull {
            canvasView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: bounds.maxY - obscuredFrame.minY,
                right: 0
            )
        } else {
            canvasView.contentInset = .zero
        }

        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }
}
