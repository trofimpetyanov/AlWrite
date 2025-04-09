import SwiftUI
import PencilKit
import Combine

class AlWriteDocument: UIDocument {
    var blocks: [DrawingBlock] = [] {
        didSet {
            if oldValue != blocks {
                updateChangeCount(.done)
            }
        }
    }

    override func contents(forType typeName: String) throws -> Any {
        let documentData = AlWriteDocumentData(
            blocks: blocks
        )

        return try JSONEncoder().encode(documentData)
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { return }

        let documentData = try JSONDecoder().decode(AlWriteDocumentData.self, from: data)
        blocks = documentData.blocks
    }
}
