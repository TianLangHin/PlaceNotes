//
//  Note.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

/// This represents a note that the user will be making, editing and recording in the app.
/// It conforms to the `IdGeneratable` protocol to indicate that it has the functionality
/// to generate a new primary key (unique ID) for every new instance being made.
///
/// It also conforms to the `Hashable` protocol so that it can be directly listed in a `ForEach`.
struct Note: Hashable, IdGeneratable {
    // These properties directly correspond to the schema defined in `DatabaseManager`.
    let id: Int
    var title: String
    var description: String
    var date: Date
    // This is a foreign key in the schema, and also directly corresponds
    // to the `id` attribute of some `Place` instance.
    let placeID: Int

    // To generate the new primary key, an internal counter is being persisted statically in the struct.
    // Every time a new ID is generated, this counter is incremented by one so the next number
    // will be higher, thus never causing any overlap.
    private static var nextId = 1

    static func uniqueId() -> Int {
        let uid = nextId
        nextId += 1
        return uid
    }

    // Upon app startup and clearing of databases, this counter may need to be reset:
    // either back to 1 when the database is empty or up to the highest primary key present in the database.
    // In both cases, this function is called with the appropriate value.
    static func resetCounter(to maximum: Int) {
        nextId = maximum + 1
    }
}
