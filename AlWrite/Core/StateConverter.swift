import Foundation

protocol StateConverter {
    associatedtype State
    associatedtype ViewState
    
    func convert(_ state: State, childCache: ViewStoreCache) -> ViewState
}

final class IdentityStateConverter<State>: StateConverter {
    func convert(_ state: State, childCache: ViewStoreCache) -> State {
        state
    }
} 
