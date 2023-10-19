import Bow
import BowEffects
import Bow

protocol EventStore {
    associatedtype AggregateType: Aggregate
    associatedtype ContextType: AggregateContext

    func loadEvents(aggregateId: String) -> IO<Error, [EventEnvelope<AggregateType>]> 
    func loadAggregate(aggregateId: String) -> IO<Error, ContextType>
    func commit(events: [AggregateType.E], context: ContextType, metadata: [String: String]) -> IO<Error, [EventEnvelope<AggregateType>]>
}

