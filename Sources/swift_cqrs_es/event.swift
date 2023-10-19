import Bow

public protocol Event: Codable {
    func eventType() -> String
    func eventVersion() -> String
}
struct EventEnvelope<A: Aggregate>: Codable {
    let aggregateId: String
    let sequence: Int
    let payload: A.E
    let metadata: [String: String]
}
