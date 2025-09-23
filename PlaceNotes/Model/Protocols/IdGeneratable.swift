//
//  IdGeneratable.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

protocol IdGeneratable {
    static func uniqueId() -> Int
    static func resetCounter(to: Int)
}
