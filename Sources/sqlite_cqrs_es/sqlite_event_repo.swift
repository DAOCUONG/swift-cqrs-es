//
//  File.swift
//
//
//  Created by Dao on 10/19/23.
//

import Foundation
import GRDB
import BowEffects
import Bow

struct SqlitePersistedEventRepository{
    let db_path: String
    let db_queue: DatabaseQueue
    
    init(db_path: String) -> SqlitePersistedEventRepository {
        
        let db_queue = try DatabaseQueue(path: db_path)
        SqlitePersistedEventRepository(db_path,db_queue)
    }
}


extension SqlitePersistedEventRepository: PersistedEventRepository{
    func getEvents<A:Aggregate>(aggregateId: String) -> IO<Error,[SerializedEvent]> {
        return IO.invoke{
            let sql_factory = SqlQueryFactory.sql_query_factory(aggregate_id)
            let fetch_events_sql = sql_factory.selectEvents
            let rows = try self.db_queue.execute(sql: fetch_events_sql, arguments:[aggregateId])
            
            let events = rows.map{row in return SerializedEvent(aggregateId: row["aggregate_id"], sequence: row["sequence"], aggregateType: row["aggregate_type"], eventType: row["event_type"], eventVersion: row"event_version", payload: row["payload"], metadata: row["metadata"]}
                                                                return events
        }^
    }
    
    func getLastEvents(aggregateId: String, lastSequence: Int)  -> IO<Error,[SerializedEvent]> {
        return IO.invoke{
                    let sql_factory = SqlQueryFactory.sql_query_factory(aggregate_id)
                    let fetch_events_sql = sql_factory.selectLastEvents
                    let rows = try self.db_queue.execute(sql: fetch_events_sql, arguments:[aggregateId, lastSequence])
                    
                    let events = rows.map{row in return SerializedEvent(aggregateId: row["aggregate_id"], sequence: row["sequence"], aggregateType: row["aggregate_type"], eventType: row["event_type"], eventVersion: row"event_version", payload: row["payload"], metadata: row["metadata"]}
                    return events
        }^
    }
    
                                                                        
                                                                        
    func getSnapshot(aggregateId: String) -> IO<Error,SerializedSnapshot> {
        return IO.invoke {
            let sql_factory = SqlQueryFactory.sql_query_factory(aggregate_id)
            let fetch_snapshot_sql = sql_factory.selectSnapshot
            let rows = try self.db_queue.execute(sql: fetch_events_sql, arguments:[aggregateId])
           
            let snapshots = rows.map{row in return
                
                 SerializedSnapshot {
                    aggregate_id: row["aggregate_id"],
                    aggregate: row["payload"]
                    current_sequence: row["last_sequence"]
                    current_snapshot: row["current_snapshot"]
               }
            }
            return snapshots.first

                            
        }^
                        
    }
    ///snapshotupdate(aggregate_id, aggregate_payload, snapshot_sequence
   
   func persist(events: [SerializedEvent]) -> IO<Error,()> {
        return  IO.invoke{
            let event = events.first!
            let sql_factory = SqlQueryFactory.sql_query_factory(event.aggregateId)
            let insert_event_sql = sql_factory.insertEvent
                            
            events.forEach { event in
                                (aggregate_type, aggregate_id, sequence, event_type, event_version, payload, metadata)
                                let rows = try self.db_queue.execute(sql: insert_event_sql, arguments:[event.aggregateType,event.aggregateId,event.sequence,event.eventType,event.eventVersion,event.payload,event.metadata])
                                
                            }
                            
            }^
                        
        }
    func snapshot(snapshot: <#T##SerializedSnapshot#>) -> IO<Error,()> {
        return IO.invoke {
            
            
            let sql_factory = SqlQueryFactory.sql_query_factory(snapshot.aggregateId)

            let insert_snapshot_sql = SqlQueryFactory.insertSnapshot
            let rows = try self.db_queue.execute(sql: insert_snapshot_sql, arguments:[snapshot.aggregateType,snapshot.aggregateId,snapshot.current_snapshot,snapshot.current_sequence,snapshot.payload])

                            
        }^
                        
                        
    }
    func streamEvents(aggregateId: String) -> IO<Error, ReplayStream> {
                        
                        
    }
                                                                        
}
