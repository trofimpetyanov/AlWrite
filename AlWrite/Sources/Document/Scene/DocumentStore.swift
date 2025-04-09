import Foundation
import Combine
import PencilKit

@MainActor
final class DocumentStore: Store {
    @Published private(set) var state: DocumentState
    var statePublisher: Published<DocumentState>.Publisher { $state }

    private let router: DocumentRouting
    private let dependenciesContainer: DocumentDependenciesContainer
    private let recognitionManager: HandwritingRecognizer
    private weak var document: AlWriteDocument?
    private var recognitionTask: Task<Void, Never>?

    private let drawingDidChangeSubject = PassthroughSubject<Void, Never>()
    private var drawingChangeSubscription: AnyCancellable?

    private typealias BlockRecognitionResult = (id: UUID, result: Result<String, Error>)

    init(router: DocumentRouting, dependenciesContainer: DocumentDependenciesContainer, document: AlWriteDocument?) {
        self.state = DocumentState()
        self.router = router
        self.dependenciesContainer = dependenciesContainer
        self.recognitionManager = dependenciesContainer.recognitionManager
        self.document = document

        setupDrawingDebouncer()
    }

    deinit {
        recognitionTask?.cancel()
        drawingChangeSubscription?.cancel()
    }

    func handle(_ event: DocumentEvent) {
        switch event {
        case .setDocument(let doc):
            self.document = doc

        case .documentLoaded(let blocks):
            state.blocks = blocks
            self.document?.blocks = blocks
            handle(.recognitionProcessNeeded)

        case .addBlock(let type):
            let newBlock = DrawingBlock(type: type)
            state.blocks.append(newBlock)
            document?.blocks = state.blocks
            document?.updateChangeCount(.done)
            handle(.recognitionProcessNeeded)

        case .updateBlockDrawing(let id, let drawing):
            if let index = state.blocks.firstIndex(where: { $0.id == id }) {
                state.blocks[index].drawing = drawing
                state.blocks[index].isModified = true
                document?.blocks = state.blocks
                document?.updateChangeCount(.done)
                drawingDidChangeSubject.send()
            }

        case .deleteRequested(let id):
            state.blocks.removeAll { $0.id == id }
            document?.blocks = state.blocks
            document?.updateChangeCount(.done)
            handle(.recognitionProcessNeeded)

        case .recognitionProcessNeeded:
            recognitionTask?.cancel()

            recognitionTask = Task { [weak self] in
                guard let self = self else { return }
                
                await MainActor.run { self.state.isRecognitionLoading = true }
                
                let blocksToProcess = self.state.blocks
                var results: [BlockRecognitionResult] = []
                
                do {
                    try await withThrowingTaskGroup(of: BlockRecognitionResult.self) { group in
                        for block in blocksToProcess {
                            if block.isModified || block.recognizedText == nil {
                                let blockId = block.id
                                let blockType = block.type
                                
                                group.addTask { [weak self] in
                                    guard let self = self else {
                                        throw CancellationError()
                                    }
                                    
                                    guard let currentBlock = await self.state.blocks.first(where: { $0.id == blockId }) else {
                                        return (id: blockId, result: .failure(CancellationError()))
                                    }
                                    let drawingToProcess = currentBlock.drawing
                                    
                                    let mode: StandardRecognitionMode = (blockType == .math) ? .math : .text
                                    await self.recognitionManager.setRecognitionMode(mode)
                                    
                                    do {
                                        let recognizedText = try await self.recognitionManager.processDrawing(drawingToProcess)
                                        return (id: blockId, result: .success(recognizedText))
                                    } catch {
                                        return (id: blockId, result: .failure(error))
                                    }
                                }
                            }
                        }
                        for try await result in group {
                            results.append(result)
                        }
                    }
                    await self.updateStateWithRecognitionResults(processedResults: results)

                } catch {
                    if !(error is CancellationError) {
                        print("Recognition TaskGroup Error: \(error)")
                    }
                    await MainActor.run { self.state.isRecognitionLoading = false }
                }
            }

        case .changeViewerPosition(let position):
            state.viewerPosition = position

        case .changeViewerProportion(let proportion):
            state.viewerProportion = proportion

        case .toggleViewer:
            state.isViewerVisible.toggle()

        case .toggleToolPicker:
            state.isToolPickerVisible.toggle()
            
        default:
            print("Unhandled DocumentEvent: \(event)")
            break
        }
    }
    
    // MARK: - Private Helpers
    private func updateStateWithRecognitionResults(processedResults: [BlockRecognitionResult]) {
        let resultMap = Dictionary(uniqueKeysWithValues: processedResults.map { ($0.id, $0.result) })

        var finalBlocks: [DrawingBlock] = []
        var combinedTextParts: [String] = []

        for index in state.blocks.indices {
            var block = state.blocks[index]
            
            if let result = resultMap[block.id] {
                switch result {
                case .success(let text):
                    block.recognizedText = text
                    block.isModified = false
                case .failure(let error):
                    if let recognitionError = error as? RecognitionError, recognitionError == .noStrokesToRecognize {
                        block.recognizedText = ""
                    } else {
                        block.recognizedText = block.recognizedText ?? "[Recognition Error]"
                    }
                    block.isModified = false
                    if !(error is RecognitionError && (error as! RecognitionError) == .noStrokesToRecognize) {
                         print("Recognition failed for block \(block.id): \(error.localizedDescription)")
                    }
                }
                state.blocks[index] = block
            }
            
            if let recognizedText = state.blocks[index].recognizedText, !recognizedText.isEmpty {
                let textToAppend = state.blocks[index].type == .math ? "$$\(recognizedText)$$" : recognizedText
                combinedTextParts.append(textToAppend)
            } else if state.blocks[index].type == .text {
                combinedTextParts.append("")
            }
        }

        state.combinedRecognizedText = combinedTextParts.joined(separator: "\n\n")
        
        state.isRecognitionLoading = false
        
        document?.blocks = state.blocks
        document?.updateChangeCount(.done)
    }

    private func setupDrawingDebouncer() {
        drawingChangeSubscription = drawingDidChangeSubject
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handle(.recognitionProcessNeeded)
            }
    }
}