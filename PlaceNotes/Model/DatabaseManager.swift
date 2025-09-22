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
    let dbName = "PlaceNotes.sqlite"
    let placesTable = "Places"
    let notesTable = "Notes"
    let dateFormatter = DateFormatter.iso()

    var success: Bool

    init() {
        // First, locate the SQLite database file.
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
                Postcode TEXT,
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
                NoteID INTEGER NOT NULL PRIMARY KEY,
                Title TEXT,
                Description TEXT,
                Date TEXT,
                PlaceID INTEGER FOREIGN KEY REFERENCES \(placesTable)(PlaceID)
            );
        """
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
            INSERT INTO \(placesTable) (PlaceID, Name, Latitude, Longitude, Postcode, Categories, Favourite)
            VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        var insertStatement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbPointer, insertString, -1, &insertStatement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int64(insertStatement, 1, Int64(place.id))
        sqlite3_bind_text(insertStatement, 2, place.name, -1, nil)
        sqlite3_bind_double(insertStatement, 3, place.latitude)
        sqlite3_bind_double(insertStatement, 4, place.longitude)
        sqlite3_bind_text(insertStatement, 5, place.postcode, -1, nil)
        sqlite3_bind_text(insertStatement, 6, place.categories.joined(separator: ","), -1, nil)
        sqlite3_bind_int(insertStatement, 7, place.isFavourite ? 1 : 0)

        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(insertStatement)
        return true
    }

    // Inserts a new `Note` instance into the `Notes` table. Returns whether the operation was successful.
    func insertNote(_ note: Note) -> Bool {
        let insertString = "INSERT INTO \(notesTable) (NoteID, Title, Description, Date, PlaceID) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil

        guard sqlite3_prepare_v2(dbPointer, insertString, -1, &insertStatement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int64(insertStatement, 1, Int64(note.id))
        sqlite3_bind_text(insertStatement, 2, note.title, -1, nil)
        sqlite3_bind_text(insertStatement, 3, note.description, -1, nil)
        sqlite3_bind_text(insertStatement, 4, dateFormatter.string(from: note.date), -1, nil)
        sqlite3_bind_int64(insertStatement, 5, Int64(note.placeID))

        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(insertStatement)
        return true
    }
}
