import Bow
import BowEffects
protocol PersistedEventRepository {
    func getEvents(aggregateId: String) -> IO<Error,[SerializedEvent]>
    func getLastEvents(aggregateId: String, lastSequence: Int)  -> IO<Error,[SerializedEvent]>
    func getSnapshot(aggregateId: String) -> IO<Error,SerializedSnapshot>
 //  func persist<A: Aggregate>(events: [SerializedEvent], snapshotUpdate: (String, Value, Int)?) 
    //func streamEvents<A: Aggregate>(aggregateId: String) async throws -> ReplayStream
    //func streamAllEvents<A: Aggregate>() async throws -> ReplayStream
}

struct SerializedEvent: Codable {
    /// The id of the aggregate instance.
    let aggregateId: String

    /// The sequence number of the event for this aggregate instance.
    let sequence: Int

    /// The type of aggregate the event applies to.
    let aggregateType: String

    /// The type of event that is serialized.
    let eventType: String

    /// The version of event that is serialized.
    let eventVersion: String

    /// The serialized domain event.
    let payload: String

    /// Additional metadata, serialized from a HashMap<String,String>.
    let metadata: Dictionary<String,String>
}

 struct SerializedSnapshot: Codable {
    /// The aggregate ID of the aggregate instance that has been loaded.
    let aggregate_id: String
    /// The current state of the aggregate instance.
    let aggregate: String
    /// The last committed event sequence number for this aggregate instance.
    let current_sequence: UInt32
    /// The last committed snapshot version for this aggregate instance.
    let current_snapshot: UInt32
}
