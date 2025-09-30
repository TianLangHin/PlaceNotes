//
//  IdGeneratable.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

/// This protocol defines the behaviour of a class that needs to generate
/// its own unique identifiers for its instances, and cannot rely on functions like `UUID()`.
/// This is applicable specifically for the data stored in the SQLite database,
/// since the database cannot always store the 128-bit integer UUID values effectively.
protocol IdGeneratable {
    // The class must implement a static function that returns an integer it knows
    // is not used by any of its instances currently.
    static func uniqueId() -> Int

    // Over time, if just an integer increment is used to look for new IDs,
    // the number may get larger than necessary. This is used to reset the internal counter
    // back to a reasonable number (e.g., back to `3` if there are only two existing instances).
    static func resetCounter(to: Int)
}
