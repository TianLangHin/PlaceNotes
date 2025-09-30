//
//  Note.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

struct Note: Hashable, IdGeneratable {
    let id: Int
    var title: String
    var description: String
    var date: Date
    let placeID: Int

    private static var nextId = 1

    static func uniqueId() -> Int {
        let uid = nextId
        nextId += 1
        return uid
    }

    static func resetCounter(to maximum: Int) {
        nextId = maximum + 1
    }
}
