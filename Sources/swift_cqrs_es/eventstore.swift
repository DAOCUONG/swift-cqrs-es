import Bow
import Foundation
import BowEffects
import Bow

protocol EventStore {
    associatedtype AggregateType: Aggregate
    associatedtype ContextType: AggregateContext

    func loadEvents(aggregateId: String) -> IO<Error, [EventEnvelope<AggregateType>]> 
    func loadAggregate(aggregateId: String) -> IO<Error, ContextType>
    func commit(events: [AggregateType.E], context: ContextType, metadata: [String: String]) -> IO<Error, [EventEnvelope<AggregateType>]>
}

enum SourceOfTruth {
    case eventStore
    case snapshot(maxSize: Int)
    case aggregateStore
    
    func commitSnapshotWithAddlEvents(currentSequence: Int, numEvents: Int) -> Int {
        switch self {
        case .eventStore:
            return 0
        case .snapshot(let maxSize):
            let nextSnapshotAt = maxSize - (currentSequence % maxSize)
            if numEvents < nextSnapshotAt {
                return 0
            } else {
                let addlEventsAfterNextSnapshot = numEvents - nextSnapshotAt
                let addlEventsAfterNextSnapshotToApply = addlEventsAfterNextSnapshot - (addlEventsAfterNextSnapshot % maxSize)
                return nextSnapshotAt + addlEventsAfterNextSnapshotToApply
            }
        case .aggregateStore:
            return numEvents
        }
    }
}
protocol EventUpcaster: AnyObject {
    /// Examines an event type and version to determine if the event should be upcasted.
    func canUpcast(eventType: String, eventVersion: String) -> Bool

    /// Modifies the serialized event to conform to the new structure.
    func upcast(event: SerializedEvent) -> SerializedEvent
}
struct PersistedEventStore<R, A> where R: PersistedEventRepository, A: Aggregate {
    let repo: R
    let storage: SourceOfTruth
    let eventUpcasters: [EventUpcaster]?
    
    init(repo: R, storage: SourceOfTruth,eventUpcasters:[EventUpcaster]?) {
        self.repo = repo
        self.storage = storage
        self.eventUpcasters = eventUpcasters
    }
    
}
/*

struct EventStoreAggregateContext<A> where A: Aggregate {
    let aggregateId: String
    var currentSequence: Int
    var aggregate: A
    
    static func contextFor(aggregateId: String, useEventStore: Bool) -> Self {
        // Implementation for creating context
        // ...
        return EventStoreAggregateContext(aggregateId: aggregateId, currentSequence: 0, aggregate: A())
    }
    
    // Other methods...
}
*/
extension PersistedEventStore: EventStore where A: Aggregate {
    func convert(events: [SerializedEvent]) -> IO<Error, [EventEnvelope<A>] >{
        IO.invoke{
            let result = try? events.map { event in
                let payload =  event.payload.data(using: .utf8)
                let jsonDecoder = JSONDecoder()
                let e = try jsonDecoder.decode(A.E.self, from:payload!)
                
                return EventEnvelope<A>(aggregateId: event.aggregateId,
                                        sequence: event.sequence,
                                        payload: e,
                                        metadata:[:] )
            }
            //TODO handlle error
            return result!
        }^
        
    }
    
    func loadAggreggate(aggregateId:String, snapshot: SerializedSnapshot, events: [SerializedEvent]) -> EventStoreAggregateContext<A> {
        let payload = snapshot.aggregate.data(using: .utf8)
        let jsonDecoder = JSONDecoder()
        var aggregate = (try? jsonDecoder.decode(A.self, from:payload!))!
      
        var state = aggregate.state
        let es1 = try? events.map{event in
            let payload =  event.payload.data(using: .utf8)
            let jsonDecoder = JSONDecoder()
            let e = try jsonDecoder.decode(A.E.self, from:payload!)
            
            return EventEnvelope<A>(aggregateId: event.aggregateId,
                                    sequence: event.sequence,
                                    payload: e,
                                    metadata:[:] )

        }
        let currentSnapshot = snapshot.current_snapshot
        var currentSequence = snapshot.current_sequence
        let es = es1!
        es.forEach { e in
             state = aggregate.apply(e.payload, state)
            currentSequence = UInt32(e.sequence)
        }
        aggregate.state = state
        return EventStoreAggregateContext(aggregateId: aggregateId, currentSequence: Int(currentSequence), currentSnapshot: Int(currentSnapshot), aggregate: aggregate)
        
    }
    
    func loadEvents(aggregateId: String) -> IO<Error, [EventEnvelope<A>]> {
            
            let get_events = IO<Error,[SerializedEvent]>.var()
            let convert_events = IO<Error, [EventEnvelope<A>]>.var()
            
            let result = binding (
                get_events <- self.repo.getEvents(aggregateId: aggregateId),
                convert_events <- self.convert(events: get_events.get),
                yield: convert_events.get
            )^
            
            
            return result
            
        
            
        
       
    }

    func loadAggregate(aggregateId: String) -> IO<Error, EventStoreAggregateContext<A>> {
        let get_last_events = IO<Error,[SerializedEvent]>.var()
        let get_snapshot = IO<Error, SerializedSnapshot>.var()
        
        let result = binding(
            get_snapshot <- self.repo.getSnapshot(aggregateId: aggregateId),
            get_last_events <- self.repo.getLastEvents(aggregateId: aggregateId, lastSequence: Int(get_snapshot.get.current_sequence)),
            yield: (get_snapshot.get, get_last_events.get)
            
        )^
        let run = try? result.runBlocking()
        
        // Implement the loading of the aggregate for the given aggregateId using PersistedEventStore's functionality
        // ...
        // Example:
        // let aggregate = self.loadAggregateFromYourRepository(aggregateId)
        return IO<Error, EventStoreAggregateContext<A>>(/* your implementation here */)
    }

    func commit(events: [A.E], context: EventStoreAggregateContext<A>, metadata: [String: String]) -> IO<Error, [EventEnvelope<A>] > {
        // Implement the commit operation for the provided events, context, and metadata using PersistedEventStore's functionality
        // ...
        // Example:
        // self.persistEventsToYourRepository(events, context, metadata)
        return IO<Error, [EventEnvelope<A>]>(/* your implementation here */)
    }
}

