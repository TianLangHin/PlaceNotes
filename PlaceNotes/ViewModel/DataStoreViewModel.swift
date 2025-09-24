//
//  DataStoreViewModel.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

class DataStoreViewModel: ObservableObject {
    let dbManager = DatabaseManager()

    @Published var places: [Place] = []
    @Published var notes: [Note] = []

    init() {
        self.refreshAllPlaces()
        self.refreshAllNotes()
    }

    func addPlace(_ place: Place) -> Bool {
        self.dbManager.insertPlace(place)
    }

    func addNote(_ note: Note) -> Bool {
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

    func refreshAllPlaces() {
        self.places = self.dbManager.fetchAllPlaces() ?? []
        Place.resetCounter(to: self.places.map { $0.id }.max() ?? 0)
    }

    func refreshAllNotes() {
        self.notes = self.dbManager.fetchAllNotes() ?? []
        Note.resetCounter(to: self.notes.map { $0.id }.max() ?? 0)
    }

    func clearAllNotes() -> Bool {
        self.dbManager.clearAllNotes()
    }

    func completeReset() {
        let _ = self.dbManager.clearAllNotes()
        let _ = self.dbManager.clearUnusedPlaces()
        Place.resetCounter(to: 0)
        Note.resetCounter(to: 0)
    }
}
