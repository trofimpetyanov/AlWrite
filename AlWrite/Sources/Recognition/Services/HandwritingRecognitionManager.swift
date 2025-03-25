@MainActor
func processDrawing(_ drawing: PKDrawing) {
    print("🖋️ RecognitionManager: Начинаю обработку рисунка в режиме: \(currentMode)")
    
    guard let engine = engineFactory.makeEngine() else {
        print("❌ RecognitionManager: Не удалось создать движок распознавания")
        delegate?.handwritingRecognitionDidComplete(text: "", error: RecognitionError.engineCreationFailed)
        return
    }
    
    DispatchQueue.main.async {
        // Создаем стратегию распознавания в зависимости от режима
        let strategy = self.getRecognitionStrategy(for: self.currentMode, engine: engine)
        
        print("🔢 RecognitionManager: Выбрана стратегия: \(strategy)")
        
        // Выполняем распознавание через стратегию
        strategy.recognizeDrawing(drawing) { [weak self] result in
            print("🔄 RecognitionManager: Распознавание завершено, результат: \(result)")
            switch result {
            case .success(let text):
                self?.delegate?.handwritingRecognitionDidComplete(text: text, error: nil)
            case .failure(let error):
                self?.delegate?.handwritingRecognitionDidComplete(text: "", error: error)
            }
        }
    }
} 