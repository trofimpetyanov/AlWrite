import Combine
import Foundation
import SwiftUI

@dynamicMemberLookup
final class ViewStore<ViewState, ViewEvent>: ObservableObject {
    private let eventHandler: (ViewEvent) -> Void
    private var viewCancellable: AnyCancellable?
    private let childCache = ViewStoreCache()

    @Published
    public private(set) var state: ViewState

    init<S: Store, SC: StateConverter, EC: EventConverter>(
        _ store: S,
        stateConverter: SC,
        eventConverter: EC,
        removingDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
    ) where S.State == SC.State, S.Event == EC.Event, ViewState == SC.ViewState, ViewEvent == EC.ViewEvent {
        eventHandler = { store.handle(eventConverter.convert($0)) }
        state = stateConverter.convert(store.state, childCache: childCache)
        viewCancellable = store
            .statePublisher
            .map { [childCache] state in
                let viewState = stateConverter.convert(state, childCache: childCache)
                childCache.cleanupUntrackedViewStores()
                return viewState
            }
            .removeDuplicates(by: isDuplicate)
            .dropFirst()
            .sink(receiveValue: { [weak self] state in
                self?.state = state
            })
    }

    convenience init<S: Store, SC: StateConverter>(
        _ store: S,
        stateConverter: SC,
        removingDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
    ) where S.State == SC.State, ViewState == SC.ViewState, S.Event == ViewEvent {
        self.init(
            store,
            stateConverter: stateConverter,
            eventConverter: IdentityEventConverter(),
            removingDuplicates: isDuplicate
        )
    }

    convenience init<S: Store, EC: EventConverter>(
        _ store: S,
        eventConverter: EC,
        removingDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
    ) where S.State == ViewState, S.Event == EC.Event, ViewEvent == EC.ViewEvent {
        self.init(
            store,
            stateConverter: IdentityStateConverter(),
            eventConverter: eventConverter,
            removingDuplicates: isDuplicate
        )
    }

    convenience init<S: Store>(
        _ store: S,
        removingDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
    ) where S.State == ViewState, S.Event == ViewEvent {
        self.init(
            store,
            stateConverter: IdentityStateConverter(),
            eventConverter: IdentityEventConverter(),
            removingDuplicates: isDuplicate
        )
    }

    func handle(_ event: ViewEvent) {
        eventHandler(event)
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<ViewState, Value>) -> Value {
        state[keyPath: keyPath]
    }
}

extension ViewStore: Equatable {
    public static func == (lhs: ViewStore<ViewState, ViewEvent>, rhs: ViewStore<ViewState, ViewEvent>) -> Bool {
        lhs === rhs
    }
}

extension ViewStore {
    func binding<T>(
        get: @escaping (ViewState) -> T,
        handle valueToEvent: @escaping (T) -> ViewEvent
    ) -> Binding<T> {
        let fallbackState = state
        return Binding { [weak self] in
            let state = self?.state ?? fallbackState
            return get(state)
        } set: { [weak self] value in
            self?.handle(valueToEvent(value))
        }
    }
}

extension ViewStore where ViewState: Equatable {
    convenience init<S: Store, SC: StateConverter, EC: EventConverter>(
        _ store: S,
        stateConverter: SC,
        eventConverter: EC
    ) where S.State == SC.State, S.Event == EC.Event, ViewState == SC.ViewState, ViewEvent == EC.ViewEvent {
        self.init(store, stateConverter: stateConverter, eventConverter: eventConverter, removingDuplicates: ==)
    }

    convenience init<S: Store, SC: StateConverter>(
        _ store: S,
        stateConverter: SC
    ) where S.State == SC.State, ViewState == SC.ViewState, S.Event == ViewEvent {
        self.init(
            store,
            stateConverter: stateConverter,
            eventConverter: IdentityEventConverter(),
            removingDuplicates: ==
        )
    }

     convenience init<S: Store, EC: EventConverter>(
        _ store: S,
        eventConverter: EC
    ) where S.State == ViewState, S.Event == EC.Event, ViewEvent == EC.ViewEvent {
        self.init(
            store,
            stateConverter: IdentityStateConverter(),
            eventConverter: eventConverter,
            removingDuplicates: ==
        )
    }

    convenience init<S: Store>(
        _ store: S
    ) where S.State == ViewState, S.Event == ViewEvent {
        self.init(store, removingDuplicates: ==)
    }
}

extension ViewStore: Identifiable where ViewState: Identifiable {
    var id: ViewState.ID { state.id }
}
