protocol Query {
    associatedtype AggregateType: Aggregate
    // Events will be dispatched here immediately after being committed.
    func dispatch(aggregateId: String, events: [EventEnvelope<AggregateType>])
}

// Equivalent Swift code for the View trait
protocol View {
    associatedtype AggregateType: Aggregate
    associatedtype S
    // Each implemented view is responsible for updating its state based on events passed via this method.
   func update(event: EventEnvelope<AggregateType>, to state: S) -> S
}