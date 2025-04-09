import SwiftUI
import LaTeXSwiftUI

struct ViewerView: View {
    @ObservedObject var viewStore: ViewStore<DocumentState, DocumentEvent>
    @State private var refreshCounter: Int = 0

    var body: some View {
        VStack {
            document
        }
        .background(Color(.secondarySystemBackground))
        .onAppear {
            refreshCounter += 1
        }
        .onChange(of: viewStore.state.combinedRecognizedText) { _, _ in
            refreshCounter += 1
        }
    }

    private var document: some View {
        ScrollView {
            LaTeX(viewStore.state.combinedRecognizedText)
                .id("latex_\(refreshCounter)")
                .padding()
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.vertical)
        .overlay {
            if viewStore.state.isRecognitionLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
}
