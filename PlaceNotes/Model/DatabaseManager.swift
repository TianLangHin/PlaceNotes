//
//  DatabaseManager.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 22/9/2025.
//

import Foundation
import SQLite3

class DatabaseManager {
    var dbPointer: OpaquePointer?
    let dbName: String
    let placesTable = "Places"
    let notesTable = "Notes"
    let dateFormatter = DateFormatter.iso()

    let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)

    var success: Bool

    init(dbName: String = "PlaceNotes.sqlite") {
        // First, locate the SQLite database file.
        self.dbName = dbName
        let dbFileURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
            .appendingPathComponent(dbName)

        // If the database file exists, then open it. Otherwise, this `DatabaseManager` has failed,
        // and `dbPointer` remains `nil`.
        guard let dbFilePath = dbFileURL?.path else {
            self.success = false
            return
        }
        guard sqlite3_open(dbFilePath, &dbPointer) == SQLITE_OK else {
            self.success = false
            return
        }

        // Next, create the two tables to be contained.
        // These are the `Locations` and `Notes` tables,
        // the latter of which references the former via a foreign key.

        // Firstly, the `Locations` table is created if it does not exist already.
        let placesTableString = """
            CREATE TABLE IF NOT EXISTS \(placesTable) (
                PlaceID INTEGER NOT NULL PRIMARY KEY,
                Name TEXT NOT NULL,
                Latitude REAL NOT NULL,
                Longitude REAL NOT NULL,
                Categories TEXT,
                Favourite BOOL NOT NULL
            );
        """
        var placesTableStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, placesTableString, -1, &placesTableStatement, nil) == SQLITE_OK else {
            self.success = false
            return
        }
        guard sqlite3_step(placesTableStatement) == SQLITE_DONE else {
            self.success = false
            return
        }
        sqlite3_finalize(placesTableStatement)

        // Secondly, the `Notes` table is created if it does not exist already.
        let notesTableString = """
            CREATE TABLE IF NOT EXISTS \(notesTable) (
                NoteID INTEGER PRIMARY KEY,
                Title TEXT,
                Description TEXT,
                Date TEXT,
                PlaceID INTEGER,
                FOREIGN KEY(PlaceID) REFERENCES \(placesTable)(PlaceID)
            );
        """
        // PlaceID INTEGER FOREIGN KEY REFERENCES \(placesTable)(PlaceID)
        var notesTableStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, notesTableString, -1, &notesTableStatement, nil) == SQLITE_OK else {
            self.success = false
            return
        }
        guard sqlite3_step(notesTableStatement) == SQLITE_DONE else {
            self.success = false
            return
        }
        sqlite3_finalize(notesTableStatement)

        self.success = true
    }

    // Inserts a new `Place` instance into the `Places` table. Returns whether the operation was successful.
    func insertPlace(_ place: Place) -> Bool {
        let insertString = """
            INSERT INTO \(placesTable) (PlaceID, Name, Latitude, Longitude, Categories, Favourite)
            VALUES (?, ?, ?, ?, ?, ?);
        """
        var insertStatement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbPointer, insertString, -1, &insertStatement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int64(insertStatement, 1, Int64(place.id))
        sqlite3_bind_text(insertStatement, 2, place.name, -1, SQLITE_TRANSIENT)
        sqlite3_bind_double(insertStatement, 3, place.latitude)
        sqlite3_bind_double(insertStatement, 4, place.longitude)
        sqlite3_bind_text(insertStatement, 5, place.categories.joined(separator: ","), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(insertStatement, 6, place.isFavourite ? 1 : 0)

        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(insertStatement)
        return true
    }

    // Inserts a new `Note` instance into the `Notes` table. Returns whether the operation was successful.
    func insertNote(_ note: Note) -> Bool {
        let insertString = """
            INSERT INTO \(notesTable) (NoteID, Title, Description, Date, PlaceID)
            VALUES (?, ?, ?, ?, ?);
        """
        var insertStatement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbPointer, insertString, -1, &insertStatement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int64(insertStatement, 1, Int64(note.id))
        sqlite3_bind_text(insertStatement, 2, note.title, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(insertStatement, 3, note.description, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(insertStatement, 4, dateFormatter.string(from: note.date), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int64(insertStatement, 5, Int64(note.placeID))

        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(insertStatement)
        return true
    }

    // Updates the value of a particular `Place` entry. Returns whether the operation was successful.
    func updatePlace(_ place: Place) -> Bool {
        let updateString = """
            UPDATE \(placesTable)
            SET Name = ?, Latitude = ?, Longitude = ?, Categories = ?, Favourite = ?
            WHERE PlaceID = ?;
        """
        var updateStatement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbPointer, updateString, -1, &updateStatement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_text(updateStatement, 1, place.name, -1, SQLITE_TRANSIENT)
        sqlite3_bind_double(updateStatement, 2, place.latitude)
        sqlite3_bind_double(updateStatement, 3, place.longitude)
        sqlite3_bind_text(updateStatement, 4, place.categories.joined(separator: ","), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(updateStatement, 5, place.isFavourite ? 1 : 0)
        sqlite3_bind_int64(updateStatement, 6, Int64(place.id))

        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(updateStatement)
        return true
    }

    // Updates the value of a particular `Note` entry. Returns whether the operation was successful.
    func updateNote(_ note: Note) -> Bool {
        let updateString = """
            UPDATE \(notesTable)
            SET Title = ?, Description = ?, Date = ?, PlaceID = ?
            WHERE NoteID = ?;
        """
        var updateStatement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbPointer, updateString, -1, &updateStatement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_text(updateStatement, 1, note.title, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(updateStatement, 2, note.description, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(updateStatement, 3, dateFormatter.string(from: note.date), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int64(updateStatement, 4, Int64(note.placeID))
        sqlite3_bind_int64(updateStatement, 5, Int64(note.id))

        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(updateStatement)
        return true
    }

    func deleteNote(by id: Int) -> Bool {
        let deleteString = """
            DELETE FROM \(notesTable)
            WHERE NoteID = ?;
        """
        var deleteStatement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbPointer, deleteString, -1, &deleteStatement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int64(deleteStatement, 1, Int64(id))

        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(deleteStatement)
        return true
    }

    func clearUnusedPlaces() -> Bool {
        let deleteString = """
            DELETE FROM \(placesTable)
            WHERE PlaceID NOT IN (SELECT DISTINCT PlaceID FROM \(notesTable)) AND Favourite = FALSE;
        """
        var deleteStatement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbPointer, deleteString, -1, &deleteStatement, nil) == SQLITE_OK else {
            return false
        }
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(deleteStatement)
        return true
    }

    func clearAllPlaces() -> Bool {
        let deleteString = """
            DELETE FROM \(placesTable)
            WHERE PlaceID NOT IN (SELECT DISTINCT PlaceID FROM \(notesTable));
        """
        var deleteStatement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbPointer, deleteString, -1, &deleteStatement, nil) == SQLITE_OK else {
            return false
        }
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(deleteStatement)
        return true
    }

    func clearAllNotes() -> Bool {
        let deleteString = "DELETE FROM \(notesTable);"
        var deleteStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, deleteString, -1, &deleteStatement, nil) == SQLITE_OK else {
            return false
        }
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(deleteStatement)
        return true
    }

    func fetchAllPlaces() -> [Place]? {
        let selectString = "SELECT * FROM \(placesTable);"
        var selectStatement: OpaquePointer? = nil
        var places: [Place] = []

        guard sqlite3_prepare_v2(dbPointer, selectString, -1, &selectStatement, nil) == SQLITE_OK else {
            return nil
        }

        while sqlite3_step(selectStatement) == SQLITE_ROW {
            let placeId = Int(sqlite3_column_int64(selectStatement, 0))
            let name = String(cString: sqlite3_column_text(selectStatement, 1))
            let latitude = sqlite3_column_double(selectStatement, 2)
            let longitude = sqlite3_column_double(selectStatement, 3)
            let categories = String(cString: sqlite3_column_text(selectStatement, 4)).split(separator: ",").map { String($0) }
            let isFavourite = sqlite3_column_int(selectStatement, 5) != 0
            let place = Place(
                id: placeId,
                name: name,
                latitude: latitude,
                longitude: longitude,
                categories: categories,
                isFavourite: isFavourite)
            places.append(place)
        }
        sqlite3_finalize(selectStatement)
        return places
    }

    func fetchAllNotes() -> [Note]? {
        let selectString = "SELECT * FROM \(notesTable);"
        var selectStatement: OpaquePointer? = nil
        var notes: [Note] = []

        guard sqlite3_prepare_v2(dbPointer, selectString, -1, &selectStatement, nil) == SQLITE_OK else {
            return nil
        }

        while sqlite3_step(selectStatement) == SQLITE_ROW {
            let noteId = Int(sqlite3_column_int64(selectStatement, 0))
            let title = String(cString: sqlite3_column_text(selectStatement, 1))
            let description = String(cString: sqlite3_column_text(selectStatement, 2))
            let dateString = String(cString: sqlite3_column_text(selectStatement, 3))
            let date = dateFormatter.date(from: dateString) ?? Date()
            let placeId = Int(sqlite3_column_int64(selectStatement, 4))
            let note = Note(id: noteId, title: title, description: description, date: date, placeID: placeId)
            notes.append(note)
        }
        sqlite3_finalize(selectStatement)
        return notes
    }
}
