import Foundation
import UIKit
import MyScriptInteractiveInk_Runtime

final class SimpleFontMetricsProvider: NSObject, IINKIFontMetricsProvider {
    func getCharacterBoundingBoxes(_ text: IINKText!, spans: [IINKTextSpan]!) -> [NSValue]! {
        var result: [NSValue] = []
        
        guard let text = text else {
            return result
        }
        
        let textString = text.label
        let fontSize: CGFloat = 16.0
        
        for _ in 0..<textString.count {
            let rect = CGRect(x: 0, y: 0, width: fontSize * 0.5, height: fontSize)
            result.append(NSValue(cgRect: rect))
        }
        
        return result
    }
    
    func getFontSizePx(_ style: IINKStyle!) -> Float {
        return 16.0
    }
    
    func getCharacterBoundingBox(_ character: String, with fontFamily: String, with fontStyle: Int32, with fontSize: CGFloat) -> CGRect {
        return CGRect(x: 0, y: 0, width: fontSize * 0.5, height: fontSize)
    }
    
    func getCharacterBoundingBoxes(_ characters: String, with fontFamily: String, with fontStyle: Int32, with fontSize: CGFloat) -> [NSValue] {
        var result: [NSValue] = []
        let width = fontSize * 0.5
        for _ in 0..<characters.count {
            let rect = CGRect(x: 0, y: 0, width: width, height: fontSize)
            result.append(NSValue(cgRect: rect))
        }
        return result
    }
    
    func getFontSizePx(with fontFamily: String, with fontStyle: Int32) -> CGFloat {
        return 16.0
    }
} 