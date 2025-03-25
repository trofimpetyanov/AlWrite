import Foundation
import PencilKit
import MyScriptInteractiveInk_Runtime

final class MyScriptRecognitionService: RecognitionService {
    private let engine: IINKEngine
    private var editor: IINKEditor?
    private var part: IINKContentPart?
    private var lastDrawing: PKDrawing?
    private var renderer: IINKRenderer?
    private var toolController: IINKToolController?
    private let fontMetricsProvider = SimpleFontMetricsProvider()
    private let mode: RecognitionMode
    
    init(engine: IINKEngine, mode: RecognitionMode) {
        self.engine = engine
        self.mode = mode
        setupEditor()
    }
    
    private func setupEditor() {
        do {
            let content = try engine.createPackage(mode.description)
            let part = try content.createPart(with: mode.partType)
            self.part = part
            
            self.renderer = try engine.createRenderer(dpiX: 96, dpiY: 96, target: nil)
            self.toolController = engine.createToolController()
            
            if let renderer = self.renderer, let editor = engine.createEditor(renderer: renderer, toolController: self.toolController) {
                self.editor = editor
                editor.set(fontMetricsProvider: fontMetricsProvider)
                try editor.set(part: part)
            }
        } catch {
        }
    }
    
    func processDrawing(_ drawing: PKDrawing) async throws -> String {
        self.lastDrawing = drawing
        
        guard let editor = editor else {
            throw RecognitionError.engineNotInitialized
        }
        
        if drawing.strokes.isEmpty {
            throw RecognitionError.noStrokesToRecognize
        }
        
        return try await Task.detached(priority: .userInitiated) { [self] in
            try editor.clear()
            try PencilKitToMyScriptConverter.convertDrawing(drawing, to: editor)
            
            return try await self.performRecognition()
        }.value
    }
    
    private func performRecognition() async throws -> String {
        guard let editor = editor else {
            throw RecognitionError.engineNotInitialized
        }
        
        await withCheckedContinuation { continuation in
            Task.detached(priority: .userInitiated) {
                editor.waitForIdle()
                continuation.resume()
            }
        }
        
        let supportedMimeTypes = editor.supportedExportMimeTypes(forSelection: nil)
        
        guard !supportedMimeTypes.isEmpty else {
            throw RecognitionError.noSupportedMimeTypes
        }
        
        if let mimeType = mode.mimeType as? IINKMimeType {
            do {
                let text = try editor.export(selection: nil, mimeType: mimeType)
                return text
            } catch {
                throw RecognitionError.exportFailed(underlyingError: error)
            }
        } else {
            throw RecognitionError.invalidMimeType
        }
    }
    
    func clear() {
        do {
            try editor?.clear()
            lastDrawing = nil
        } catch {
        }
    }
}