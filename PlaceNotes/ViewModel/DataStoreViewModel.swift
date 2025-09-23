//
//  DataStoreViewModel.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

class DataStoreViewModel: ObservableObject {
    let dbManager = DatabaseManager()

    func insertPlace(_ place: Place) -> Bool {
        self.dbManager.insertPlace(place)
    }

    func insertNote(_ note: Note) -> Bool {
        self.dbManager.insertNote(note)
    }

    func updatePlace(_ place: Place) -> Bool {
        self.dbManager.updatePlace(place)
    }

    func deleteNote(by id: Int) -> Bool {
        self.dbManager.deleteNote(by: id)
    }

    func clearUnusedPlaces() -> Bool {
        self.dbManager.clearUnusedPlaces()
    }

    func fetchAllPlaces() -> [Place]? {
        self.dbManager.fetchAllPlaces()
    }

    func fetchAllNotes() -> [Note]? {
        self.dbManager.fetchAllNotes()
    }

    func clearAllNotes() -> Bool {
        self.dbManager.clearAllNotes()
    }
}
