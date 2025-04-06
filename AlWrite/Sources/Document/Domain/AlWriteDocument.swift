import SwiftUI
import UniformTypeIdentifiers
import PencilKit
import Combine

class AlWriteDocument: UIDocument {
    var drawing: PKDrawing = PKDrawing() {
        didSet {
            if oldValue != drawing {
                updateChangeCount(.done)
            }
        }
    }

    override func contents(forType typeName: String) throws -> Any {
        let documentData = AlWriteDocumentData(
            drawing: drawing
        )

        return try JSONEncoder().encode(documentData)
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { return }

        let documentData = try JSONDecoder().decode(AlWriteDocumentData.self, from: data)
        drawing = documentData.drawing
    }
}
