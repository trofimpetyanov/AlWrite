import Foundation

protocol EventConverter {
    associatedtype Event
    associatedtype ViewEvent

    func convert(_ viewEvent: ViewEvent) -> Event
}

final class IdentityEventConverter<Event>: EventConverter {
    func convert(_ viewEvent: Event) -> Event {
        viewEvent
    }
} 
