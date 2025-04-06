import SwiftUI
import PencilKit

struct ViewerView: View {
    @ObservedObject var viewStore: ViewStore<ViewerState, ViewerEvent>

    @State private var mode: ViewerState.ViewerRecognitionMode = .text

    var body: some View {
        VStack {
            header
            document
        }
        .background(Color(.secondarySystemBackground))
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
            .fixedSize()
            .onChange(of: mode) { _, newValue in
                viewStore.handle(.switchRecognitionMode(mode))
            }

            Spacer()

            Button {
                viewStore.handle(.recognizeRequested)
            } label: {
                if viewStore.state.isLoading {
                    ProgressView()
                        .colorScheme(.dark)
                } else {
                    Text("Распознать")
                }
            }
            .controlSize(.regular)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .animation(.smooth, value: viewStore.state.isLoading)
        }
        .padding()
    }

    private var document: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemBackground))
            .overlay {
                Text(viewStore.state.recognizedText)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
