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
        let success = self.dbManager.insertPlace(place)
        self.refresh()
        return success
    }

    func addNote(_ note: Note) -> Bool {
        let success = self.dbManager.insertNote(note)
        self.refresh()
        return success
    }

    func updatePlace(_ place: Place) -> Bool {
        let success = self.dbManager.updatePlace(place)
        self.refresh()
        return success
    }

    func deleteNote(by id: Int) -> Bool {
        let success = self.dbManager.deleteNote(by: id)
        self.refresh()
        return success
    }

    func clearUnusedPlaces() -> Bool {
        let success = self.dbManager.clearUnusedPlaces()
        self.refresh()
        return success
    }

    func refreshAllPlaces() {
        self.places = self.dbManager.fetchAllPlaces() ?? []
        Place.resetCounter(to: self.places.map { $0.id }.max() ?? 0)
    }

    func refreshAllNotes() {
        self.notes = self.dbManager.fetchAllNotes() ?? []
        Note.resetCounter(to: self.notes.map { $0.id }.max() ?? 0)
    }

    func refresh() {
        self.refreshAllPlaces()
        self.refreshAllNotes()
    }

    func clearAllNotes() -> Bool {
        self.dbManager.clearAllNotes()
    }

    func completeReset() {
        let _ = self.dbManager.clearAllNotes()
        let _ = self.dbManager.clearUnusedPlaces()
        self.refresh()
    }

    func getPlace(by id: Int) -> Place? {
        return self.places.first(where: { $0.id == id })
    }
}
