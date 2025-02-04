import Combine

@MainActor
protocol Store {
    associatedtype State
    associatedtype Event
    
    var state: State { get }
    var statePublisher: Published<State>.Publisher { get }
    
    func handle(_ event: Event)
} 
