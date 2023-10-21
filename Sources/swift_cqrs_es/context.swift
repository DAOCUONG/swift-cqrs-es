
struct EventStoreAggregateContext<A: Aggregate>: AggregateContext {
    let aggregateId: String
    let currentSequence: Int
    let currentSnapshot: Int?
    private let aggregateValue: A

    init(aggregateId: String, currentSequence: Int, currentSnapshot: Int?, aggregate: A) {
        self.aggregateId = aggregateId
        self.currentSequence = currentSequence
        self.currentSnapshot = currentSnapshot
        self.aggregateValue = aggregate
    }

    func aggregate() -> A {
        return aggregateValue
    }
}

protocol AggregateContext {
    associatedtype AggregateType: Aggregate
    func aggregate() -> AggregateType
}


