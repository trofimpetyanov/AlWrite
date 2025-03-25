import Foundation

final class RecognitionEngineFactory {
    
    init() {}
    
    func createMyScriptEngine() -> RecognitionEngine {
        MyScriptRecognitionEngine()
    }
    
    func createDefaultEngine() -> RecognitionEngine {
        createMyScriptEngine()
    }
}
