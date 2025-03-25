import Foundation
import PencilKit
import MyScriptInteractiveInk_Runtime

final class PencilKitToMyScriptConverter {
    
    static func convertDrawing(_ drawing: PKDrawing, to editor: IINKEditor) throws {
        try editor.pointerCancel(0)
        
        for stroke in drawing.strokes {
            try convertStroke(stroke, to: editor)
        }
    }
    
    static func convertStroke(_ stroke: PKStroke, to editor: IINKEditor) throws {
        let path = stroke.path
        
        let interpolatedPoints = path.interpolatedPoints(in: nil, by: .distance(1.0))
        let pointsArray = Array(interpolatedPoints)
        
        guard !pointsArray.isEmpty else { return }
        
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        
        let firstPoint = pointsArray.first!
        try editor.pointerDown(
            point: CGPoint(x: firstPoint.location.x, y: firstPoint.location.y),
            timestamp: timestamp,
            force: Float(firstPoint.force),
            type: .pen,
            pointerId: 0
        )
        
        for point in pointsArray.dropFirst().dropLast() {
            try editor.pointerMove(
                point: CGPoint(x: point.location.x, y: point.location.y),
                timestamp: timestamp,
                force: Float(point.force),
                type: .pen,
                pointerId: 0
            )
        }
        
        if pointsArray.count > 1 {
            let lastPoint = pointsArray.last!
            try editor.pointerUp(
                point: CGPoint(x: lastPoint.location.x, y: lastPoint.location.y),
                timestamp: timestamp,
                force: Float(lastPoint.force),
                type: .pen,
                pointerId: 0
            )
        }
    }
    
    static func addStroke(_ stroke: PKStroke, to editor: IINKEditor) throws {
        try convertStroke(stroke, to: editor)
    }
} 