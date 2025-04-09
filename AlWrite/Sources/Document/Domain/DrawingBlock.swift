import Foundation
import PencilKit

struct DrawingBlock: Identifiable, Codable {
    enum BlockType: String, Codable, Equatable {
        case text
        case math
    }

    let id: UUID
    var drawing: PKDrawing
    var type: BlockType
    var recognizedText: String?
    var isModified: Bool

    init(
        id: UUID = UUID(),
        drawing: PKDrawing = PKDrawing(),
        type: BlockType,
        recognizedText: String? = nil,
        isModified: Bool = true
    ) {
        self.id = id
        self.drawing = drawing
        self.type = type
        self.recognizedText = recognizedText
        self.isModified = isModified
    }
} 

extension DrawingBlock: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension DrawingBlock: Equatable {
    static func == (lhs: DrawingBlock, rhs: DrawingBlock) -> Bool {
        return lhs.id == rhs.id
    }
}
