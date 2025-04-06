import SwiftUI
import PencilKit
import LaTeXSwiftUI

struct ViewerView: View {
    @ObservedObject var viewStore: ViewStore<ViewerState, ViewerEvent>
    @State private var mode: ViewerState.ViewerRecognitionMode = .text
    @State private var refreshCounter: Int = 0

    @Environment(\.scenePhase) private var scenePhase

    private var formattedLatexString: String {
        guard viewStore.state.recognitionMode == .math,       !viewStore.state.recognizedText.isEmpty
        else { return "" }

        let text = viewStore.state.recognizedText

        if !text.hasPrefix("$") && !text.hasSuffix("$") {
            return "$\(text)$"
        }

        return text
    }

    var body: some View {
        VStack {
            header
            document
        }
        .background(Color(.secondarySystemBackground))
        .onAppear {
            viewStore.handle(.appeared)
            refreshCounter += 1
        }
        .onChange(of: viewStore.state.recognizedText) { _, _ in
            refreshCounter += 1
        }
        .onChange(of: viewStore.state.recognitionMode) { _, newValue in
            refreshCounter += 1
        }
    }

    private var header: some View {
        HStack {
            Picker(selection: $mode) {
                ForEach(ViewerState.ViewerRecognitionMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue)
                        .tag(mode)
                }
            } label: {
                Text("Режим распознавания")
            }
            .pickerStyle(.palette)
            .onChange(of: mode) { _, newValue in
                viewStore.handle(.switchRecognitionMode(mode))
            }
        }
        .padding()
    }

    private var document: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemBackground))
            .overlay {
                if viewStore.state.recognitionMode == .math {
                    LaTeX(formattedLatexString)
                        .id("latex_\(refreshCounter)")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    Text(viewStore.state.recognizedText)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)
    }
}


#Preview("Light") {
    ViewerView(
        viewStore: ViewStore(
            ViewerStore(
                dependenciesContainer: ViewerDependenciesContainer(
                    recognitionManager: MockHandwritingRecognizer()
                )
            )
        )
    )
}

#Preview("Dark") {
    ViewerView(
        viewStore: ViewStore(
            ViewerStore(
                dependenciesContainer: ViewerDependenciesContainer(
                    recognitionManager: MockHandwritingRecognizer()
                )
            )
        )
    )
    .colorScheme(.dark)
}

private class MockHandwritingRecognizer: HandwritingRecognizer {
    var delegate: HandwritingRecognitionDelegate?
    func setRecognitionMode(_ mode: StandardRecognitionMode) {}
    func processDrawing(_ drawing: PKDrawing) {}
}
