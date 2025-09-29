//
//  DataStoreViewModel.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

/// The single class that all Views of the app will access the database through.
/// It internally uses a `DatabaseManager` object which handles the heavy lifting of backend SQL logic.
/// The purpose of this class is to provide an `ObservableObject` class that can be
/// used as an EnvironmentObject, and always keeping updated `places` and `notes` arrays
/// so that Views can efficiently be updated with the most recent correct source of information.
class DataStoreViewModel: ObservableObject {
    /// The internal `DatabaseManager` object. All persistence is handled through `dbManager`.
    let dbManager = DatabaseManager()

    /// Both `notes` and `places` are observable properties that provide
    /// a list of all the notes currently kept by the user
    /// and the list of all places the notes are attached to.
    @Published var notes: [Note] = []
    @Published var places: [Place] = []

    /// Upon startup, the `refresh` method is called, which will
    /// populate `notes` and `places` with any data already existing in the SQLite database.
    init() {
        self.refresh()
    }

    /// The following seven methods serve mostly as an interface that works similar to
    /// the `DatabaseManager` class, allowing its internal functionality to be easily accessible
    /// by other parts of the code.
    /// In each, it adds on the functionality that `notes` and `places` get immediately refreshed.

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

    func updateNote(_ note: Note) -> Bool {
        let success = self.dbManager.updateNote(note)
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

    func clearAllNotes() -> Bool {
        let success = self.dbManager.clearAllNotes()
        self.refresh()
        return success
    }

    /// Updates the `notes` and `places` arrays to reflect exactly what the SQLite database currently stores.
    /// This triggers an observable change so that Views can instantly a change in the stored data.
    func refresh() {
        self.notes = self.dbManager.fetchAllNotes() ?? []
        // After fetching all the stored `Note` instances,
        // the internal static counter of `Note` is set to the largest integer seen in the database,
        // ensuring that no primary key clashes occur in future insertions.
        Note.resetCounter(to: self.notes.map { $0.id }.max() ?? 0)

        self.places = self.dbManager.fetchAllPlaces() ?? []
        // The internal static counter of `Place` is set, just as it is done for `Note`.
        Place.resetCounter(to: self.places.map { $0.id }.max() ?? 0)
    }

    /// Clears all the data stored in the SQLite database.
    func completeReset() {
        let _ = self.dbManager.clearAllNotes()
        let _ = self.dbManager.clearAllPlaces()
        self.refresh()
    }

    /// Returns the `Place` instance stored in the SQLite database using its primary key.
    /// A `nil` is returned if such a primary key is not present.
    func getPlace(by id: Int) -> Place? {
        return self.places.first(where: { $0.id == id })
    }

    /// Returns the `Note` instance stored in the SQLite database using its primary key.
    /// A `nil` is returned if such a primary key is not present.
    func getNote(by id: Int) -> Note? {
        return self.notes.first(where: { $0.id == id })
    }
}
