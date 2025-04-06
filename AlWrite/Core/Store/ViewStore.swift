import Combine
import Foundation

@MainActor
final class ViewStore<ViewState, ViewEvent>: ObservableObject {
    private let eventHandler: (ViewEvent) -> Void
    private var cancellable: AnyCancellable?
    
    @Published
    private(set) var state: ViewState
    
    init<S: Store>(_ store: S) where S.State == ViewState, S.Event == ViewEvent {
        self.state = store.state
        self.eventHandler = store.handle
        
        self.cancellable = store.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.state = state
            }
    }
    
    func handle(_ event: ViewEvent) {
        eventHandler(event)
    }
} 
