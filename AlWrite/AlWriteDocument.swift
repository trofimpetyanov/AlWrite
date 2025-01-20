import UIKit
import PencilKit

class AlWriteDocument: UIDocument {
    var drawing: PKDrawing? {
        didSet {
            if oldValue != drawing {
                self.updateChangeCount(.done)
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

struct AlWriteDocumentData: Codable {
    let drawing: PKDrawing?
}
