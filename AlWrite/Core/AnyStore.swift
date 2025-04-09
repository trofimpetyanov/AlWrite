import Combine
import Foundation

public class AnyStore<State, Event> {
    private let base: AnyStoreBase<State, Event>

    public init<S: Store>(
        _ concrete: S
    ) where S.State == State, S.Event == Event {
        base = AnyStoreBox(concrete: concrete)
    }
}

extension AnyStore: Store {

    public var state: State {
        base.state
    }

    public var statePublisher: Published<State>.Publisher {
        base.statePublisher
    }

    public func handle(_ event: Event) {
        base.handle(event)
    }
}

private class AnyStoreBase<State, Event> {
    var state: State {
        fatalError("Abstract getter")
    }

    var statePublisher: Published<State>.Publisher {
        fatalError("Abstract getter")
    }

    func handle(_ event: Event) {
        fatalError("Abstract method")
    }
}

private final class AnyStoreBox<Concrete: Store>: AnyStoreBase<Concrete.State, Concrete.Event> {
    let concrete: Concrete

    override var state: Concrete.State {
        concrete.state
    }

    override var statePublisher: Published<Concrete.State>.Publisher {
        concrete.statePublisher
    }

    init(
        concrete: Concrete
    ) {
        self.concrete = concrete
    }

    override func handle(_ event: Concrete.Event) {
        concrete.handle(event)
    }
}
