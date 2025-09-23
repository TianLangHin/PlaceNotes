//
//  Place.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

struct Place: Identifiable, IdGeneratable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let postcode: String
    let categories: [String]
    var isFavourite: Bool

    private static var nextId = 1

    static func uniqueId() -> Int {
        let uid = nextId
        nextId += 1
        return uid
    }

    static func resetCounter(to maximum: Int) {
        nextId = max(nextId, maximum + 1)
    }
}
