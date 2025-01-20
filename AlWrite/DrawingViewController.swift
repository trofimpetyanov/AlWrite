import UIKit
import PencilKit

class DrawingViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
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
    
    private let standardPageWidth: CGFloat = 595.2
    private let standardPageHeight: CGFloat = 841.8
    
    var drawing: PKDrawing? {
        get { canvasView.drawing }
        set {
            canvasView.drawing = newValue ?? PKDrawing()
            updateContentSizeForDrawing()
        }
    }
    
    var drawingChanged: ((PKDrawing) -> Void)?
    
    private var isToolPickerVisible = true
    
    var visibleTopPoint: CGFloat {
        return canvasView.contentOffset.y + canvasView.adjustedContentInset.top
    }
    
    var sideViewHeight: CGFloat = 0
    
    private var previousTopPoint: CGFloat = 0
    
    func maintainVisibleTop(_ topPoint: CGFloat, sideViewWidth: CGFloat) {
        let fullWidth = canvasView.bounds.width + sideViewWidth
        let widthRatio = fullWidth / canvasView.bounds.width
        
        let adjustedTopPoint: CGFloat
        if sideViewWidth > 0 {
            adjustedTopPoint = topPoint / widthRatio
            previousTopPoint = topPoint
        } else {
            adjustedTopPoint = previousTopPoint * widthRatio
        }
        
        let newY = max(0, adjustedTopPoint - canvasView.adjustedContentInset.top)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        canvasView.setContentOffset(CGPoint(
            x: canvasView.contentOffset.x,
            y: newY
        ), animated: false)
        CATransaction.commit()
    }
    
    var scrollProgress: CGFloat {
        let visibleHeight = canvasView.bounds.height - canvasView.adjustedContentInset.top - canvasView.adjustedContentInset.bottom - canvasView.safeAreaInsets.top - canvasView.safeAreaInsets.bottom
        let totalScrollableHeight = max(0, canvasView.contentSize.height - visibleHeight)
        
        guard totalScrollableHeight > 0 else { return 0 }
        
        let adjustedOffset = canvasView.contentOffset.y + canvasView.adjustedContentInset.top + canvasView.safeAreaInsets.top
        let adjustedVisibleHeight = visibleHeight - canvasView.adjustedContentInset.top - canvasView.adjustedContentInset.bottom - canvasView.safeAreaInsets.top - canvasView.safeAreaInsets.bottom
        
        return adjustedOffset / (totalScrollableHeight + adjustedVisibleHeight)
    }
    
    func maintainScrollProgress(_ progress: CGFloat) {
        let visibleHeight = canvasView.bounds.height - canvasView.adjustedContentInset.top - canvasView.adjustedContentInset.bottom - canvasView.safeAreaInsets.top - canvasView.safeAreaInsets.bottom
        let totalScrollableHeight = max(0, canvasView.contentSize.height - visibleHeight)
        
        let adjustedVisibleHeight = visibleHeight - canvasView.adjustedContentInset.top - canvasView.adjustedContentInset.bottom - canvasView.safeAreaInsets.top - canvasView.safeAreaInsets.bottom
        
        let newY = progress == 0
            ? -canvasView.adjustedContentInset.top - canvasView.safeAreaInsets.top
            : (progress * (totalScrollableHeight + adjustedVisibleHeight)) - canvasView.adjustedContentInset.top - canvasView.safeAreaInsets.top
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        canvasView.setContentOffset(CGPoint(
            x: canvasView.contentOffset.x,
            y: newY
        ), animated: false)
        CATransaction.commit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCanvas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isToolPickerVisible {
            canvasView.becomeFirstResponder()
            toolPicker.setVisible(true, forFirstResponder: canvasView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCanvasScale()
    }
    
    private func setupCanvas() {
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
    }
    
    private func updateCanvasScale() {
        let scale = view.bounds.width / standardPageWidth
        canvasView.minimumZoomScale = scale
        canvasView.maximumZoomScale = scale * 5
        canvasView.zoomScale = scale
        
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
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
    
    // MARK: - PKCanvasViewDelegate
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
        drawingChanged?(canvasView.drawing)
    }
    
    // MARK: - PKToolPickerObserver
    
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
    
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
    
    private func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        
        if !obscuredFrame.isNull {
            canvasView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: view.bounds.maxY - obscuredFrame.minY,
                right: 0
            )
        } else {
            canvasView.contentInset = .zero
        }
        
        canvasView.scrollIndicatorInsets = canvasView.contentInset
    }
    
    func setToolPickerVisible(_ visible: Bool) {
        isToolPickerVisible = visible
        
        if visible && !canvasView.isFirstResponder {
            canvasView.becomeFirstResponder()
        }
        
        toolPicker.setVisible(visible, forFirstResponder: canvasView)
        
        if !visible {
            canvasView.resignFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isToolPickerVisible && !toolPicker.isVisible {
            canvasView.becomeFirstResponder()
            toolPicker.setVisible(true, forFirstResponder: canvasView)
        }
    }
} 
