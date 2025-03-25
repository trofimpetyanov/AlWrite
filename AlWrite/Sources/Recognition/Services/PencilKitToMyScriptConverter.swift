import Foundation
import PencilKit
import MyScriptInteractiveInk_Runtime

final class PencilKitToMyScriptConverter {
    
    static func convertDrawing(_ drawing: PKDrawing, to editor: IINKEditor) throws {
        for i in 0..<10 {
            try? editor.pointerCancel(i)
        }
        
        for (index, stroke) in drawing.strokes.enumerated() {
            let pointerId = (index % 9) + 1
            try convertStroke(stroke, to: editor, pointerId: Int32(pointerId))
            try editor.pointerCancel(pointerId)
        }
    }
    
    static func convertStroke(_ stroke: PKStroke, to editor: IINKEditor, pointerId: Int32 = 0) throws {
        let path = stroke.path
        
        let interpolatedPoints = path.interpolatedPoints(in: nil, by: .distance(1.0))
        let pointsArray = Array(interpolatedPoints)
        
        guard !pointsArray.isEmpty else {
            return
        }

        let startTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
        
        let firstPoint = pointsArray.first!
        try editor.pointerDown(
            point: CGPoint(x: firstPoint.location.x, y: firstPoint.location.y),
            timestamp: startTimestamp,
            force: Float(firstPoint.force),
            type: .pen,
            pointerId: Int(pointerId)
        )

        let timeStep: Int64 = 10
        var timestamp = startTimestamp
        
        for point in pointsArray.dropFirst().dropLast() {
            timestamp += timeStep
            try editor.pointerMove(
                point: CGPoint(x: point.location.x, y: point.location.y),
                timestamp: timestamp,
                force: Float(point.force),
                type: .pen,
                pointerId: Int(pointerId)
            )
        }
        
        if pointsArray.count > 1 {
            let lastPoint = pointsArray.last!
            timestamp += timeStep
            try editor.pointerUp(
                point: CGPoint(x: lastPoint.location.x, y: lastPoint.location.y),
                timestamp: timestamp,
                force: Float(lastPoint.force),
                type: .pen,
                pointerId: Int(pointerId)
            )
        }
    }
    
    static func addStroke(_ stroke: PKStroke, to editor: IINKEditor) throws {
        try? editor.pointerCancel(1)
        try convertStroke(stroke, to: editor, pointerId: 1)
        try editor.pointerCancel(1)
    }
} 
