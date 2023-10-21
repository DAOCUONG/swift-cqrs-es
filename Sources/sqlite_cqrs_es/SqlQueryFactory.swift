//
//  File.swift
//  
//
//  Created by Dao on 10/19/23.
//

import Foundation
let kevent_prefix = "events_"
let ksnapshot_prefix = "snapshot_"
struct SqlQueryFactory {
    let eventTable: String
    let selectEvents: String
    let selectLastEvents: String
    let insertEvent: String
    let allEvents: String
    let insertSnapshot: String
    let updateSnapshot: String
    let selectSnapshot: String
    static func sql_query_factory(aggregate_id: String) ->SqlQueryFactory {
       return SqlQueryFactory(kevent_prefix+aggregate_id,ksnapshot_prefix+aggregate_id)
    }
    init(_ eventTable: String, _ snapshotTable: String) {
        self.eventTable = eventTable
        
        self.selectEvents = """
        SELECT aggregate_type, aggregate_id, sequence, event_type, event_version, payload, metadata
        FROM \(eventTable)
        WHERE aggregate_id = ?
        ORDER BY sequence
        """
        self.selectLastEvents = """
        SELECT aggregate_type, aggregate_id, sequence, event_type, event_version, payload, metadata
        FROM \(eventTable)
        WHERE aggregate_id = ? AND sequence >= ?
        ORDER BY sequence
        """
        
        self.insertEvent = """
        INSERT INTO \(eventTable) (aggregate_type, aggregate_id, sequence, event_type, event_version, payload, metadata)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)
        """
        
        self.allEvents = """
        SELECT aggregate_type, aggregate_id, sequence, event_type, event_version, payload, metadata
        FROM \(eventTable)
        WHERE aggregate_type = ?1
        ORDER BY sequence
        """
        
        self.insertSnapshot = """
        INSERT INTO \(snapshotTable) (aggregate_type, aggregate_id, last_sequence, current_snapshot, payload)
        VALUES (?1, ?2, ?3, ?4, ?5)
        """
        
        self.updateSnapshot = """
        UPDATE \(snapshotTable)
        SET last_sequence = ?3, payload = ?6, current_snapshot = ?4
        WHERE aggregate_type = ?1 AND aggregate_id = ?2 AND current_snapshot = ?5
        """
        
        self.selectSnapshot = """
        SELECT aggregate_type, aggregate_id, last_sequence, current_snapshot, payload
        FROM \(snapshotTable)
        WHERE  aggregate_id = ? and last_sequence = (SELECT MAX(last_sequence) FROM \(snapshotTable))
        LIMIT 1
        """
        
        SELECT * FROM your_table
        WHERE your_column = (SELECT MAX(your_column) FROM your_table)
        LIMIT 1;
    }
    
    func getLastEvents(lastSequence: Int) -> String {
        return """
        SELECT aggregate_type, aggregate_id, sequence, event_type, event_version, payload, metadata
        FROM \(eventTable)
        WHERE aggregate_type = ?1 AND aggregate_id = ?2 AND sequence > \(lastSequence)
        ORDER BY sequence
        """
    }
}
