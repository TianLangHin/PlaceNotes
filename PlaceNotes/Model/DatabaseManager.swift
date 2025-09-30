//
//  DatabaseManager.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 22/9/2025.
//

import Foundation
import SQLite3

/// This class manages the persistent data storage using SQLite.
/// It has a pointer to the SQLite database which contains two tables: one for Notes and one for known Places.
class DatabaseManager {
    // The database pointer, which will point to the location of the SQLite database.
    // This will not change throughout the lifetime of this class.
    var dbPointer: OpaquePointer?

    // By default, this database name will be "PlaceNotes.sqlite",
    // as per the default argument in the constructor.
    let dbName: String

    // These are the names of the tables, listed here rather than hard-coded to each individual query string,
    // enhancing maintainability and generalisability.
    let placesTable = "Places"
    let notesTable = "Notes"

    // Since the database will have to record dates as well,
    // a single `DateFormatter` instance is used for all conversions to and from `Date` and string instances.
    let dateFormatter = DateFormatter.iso()

    // This is the flag that is required to translate correctly between the internal representation of strings
    // in the SQLite database and in native Swift.
    let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)

    // An indicator that shows whether the database initialisation was successful or not.
    var success: Bool

    init(dbName: String = "PlaceNotes.sqlite") {
        // The supplying of an optional name argument allows the testing of database queries
        // in a separate non-production environment.
        self.dbName = dbName

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
                Categories TEXT NOT NULL,
                Favourite BOOL NOT NULL
            );
        """
        // The SQL statement is represented as a pointer to some place within the database.
        var placesTableStatement: OpaquePointer? = nil
        // The SQL string is first used to prepare the statement.
        guard sqlite3_prepare_v2(dbPointer, placesTableString, -1, &placesTableStatement, nil) == SQLITE_OK else {
            // If any step fails, the `success` property is set to false and the construction is terminated.
            self.success = false
            return
        }
        // Then, the SQL statement is executed.
        guard sqlite3_step(placesTableStatement) == SQLITE_DONE else {
            self.success = false
            return
        }
        // Finally, the allocated resources for the SQL query is freed to prevent memory leaks and.
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
        // The steps for creating the table are similar to the above for the Places table.
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

        // If the above had been executed successfully, then `success` will be set to true.
        self.success = true
    }

    // Inserts a new `Place` instance into the `Places` table. Returns whether the operation was successful.
    func insertPlace(_ place: Place) -> Bool {
        // The SQL insert statement inserts a single entry into the Places table.
        // This is done using the VALUES keyword and bindings using `?`.
        // This method of value binding also prevents SQL injection attacks.
        let insertString = """
            INSERT INTO \(placesTable) (PlaceID, Name, Latitude, Longitude, Categories, Favourite)
            VALUES (?, ?, ?, ?, ?, ?);
        """

        // Firstly, the insert statement is prepared and set up.
        var insertStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, insertString, -1, &insertStatement, nil) == SQLITE_OK else {
            return false
        }

        // Then, the properties of the `Place` instance are binded to each of the `?` occurrences
        // within the SQL insert statement. For all text/string bindings, the `SQLITE_TRANSIENT` reference
        // is used to translate between string representations correctly. Additionally, the boolean `isFavourite`
        // property is stored as an integer, since SQLite does not natively handle booleans.
        sqlite3_bind_int64(insertStatement, 1, Int64(place.id))
        sqlite3_bind_text(insertStatement, 2, place.name, -1, SQLITE_TRANSIENT)
        sqlite3_bind_double(insertStatement, 3, place.latitude)
        sqlite3_bind_double(insertStatement, 4, place.longitude)
        // For `Categories` in particular, since the corresponding `place.categories` is a list of strings
        // but the SQLite database cannot store a list in a single data point,
        // this is encoded as a comma-delimited string instead.
        sqlite3_bind_text(insertStatement, 5, place.categories.joined(separator: ","), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(insertStatement, 6, place.isFavourite ? 1 : 0)

        // After binding the values, the SQL insert statement is executed.
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            return false
        }
        // After the statement has been executed, the resoruces are freed.
        sqlite3_finalize(insertStatement)
        return true
    }

    // Inserts a new `Note` instance into the `Notes` table. Returns whether the operation was successful.
    func insertNote(_ note: Note) -> Bool {
        let insertString = """
            INSERT INTO \(notesTable) (NoteID, Title, Description, Date, PlaceID)
            VALUES (?, ?, ?, ?, ?);
        """

        // The insert statement is prepared.
        var insertStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, insertString, -1, &insertStatement, nil) == SQLITE_OK else {
            return false
        }

        // Each of the properties of the `Note` are binded to the SQL statement.
        sqlite3_bind_int64(insertStatement, 1, Int64(note.id))
        sqlite3_bind_text(insertStatement, 2, note.title, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(insertStatement, 3, note.description, -1, SQLITE_TRANSIENT)
        // The `dateFormatter` property is used to convert the date to a string for storage within SQLite.
        sqlite3_bind_text(insertStatement, 4, dateFormatter.string(from: note.date), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int64(insertStatement, 5, Int64(note.placeID))

        // The statement is then executed.
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            return false
        }

        // The resources are then freed to prevent memory leaks.
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

        // The SQL Update statement is prepared first.
        var updateStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, updateString, -1, &updateStatement, nil) == SQLITE_OK else {
            return false
        }

        // The values are binded to the statement, with the string bindings
        // using the `SQLITE_TRANSIENT` resource for proper conversion between representations.
        sqlite3_bind_text(updateStatement, 1, place.name, -1, SQLITE_TRANSIENT)
        sqlite3_bind_double(updateStatement, 2, place.latitude)
        sqlite3_bind_double(updateStatement, 3, place.longitude)
        // `place.categories` is an array of strings, but needs to be stored as a string.
        // Hence, a comma-delimited representation is used (and is used consistently throughout this class).
        sqlite3_bind_text(updateStatement, 4, place.categories.joined(separator: ","), -1, SQLITE_TRANSIENT)
        // Booleans have to be stored as integers in SQLite.
        sqlite3_bind_int(updateStatement, 5, place.isFavourite ? 1 : 0)
        // The ID is the last element being binded since this is the condition on which the update is made.
        sqlite3_bind_int64(updateStatement, 6, Int64(place.id))

        // The statement is executed.
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            return false
        }
        // Allocated resources are finally freed.
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

        // The SQL Update statement is prepared first.
        var updateStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, updateString, -1, &updateStatement, nil) == SQLITE_OK else {
            return false
        }

        // Each of the properties of the `Note` are binded to the SQL statement.
        sqlite3_bind_text(updateStatement, 1, note.title, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(updateStatement, 2, note.description, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(updateStatement, 3, dateFormatter.string(from: note.date), -1, SQLITE_TRANSIENT)
        sqlite3_bind_int64(updateStatement, 4, Int64(note.placeID))
        // The ID is the last element being binded since this is the condition on which the update is made.
        sqlite3_bind_int64(updateStatement, 5, Int64(note.id))

        // The statement is executed.
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            return false
        }
        // Finally, resources are freed.
        sqlite3_finalize(updateStatement)
        return true
    }

    // Deletes a particular `Note` entry based on its primary key. Returns whether the operation was successful.
    func deleteNote(by id: Int) -> Bool {
        let deleteString = """
            DELETE FROM \(notesTable)
            WHERE NoteID = ?;
        """

        // The SQL Delete statement is prepared.
        var deleteStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, deleteString, -1, &deleteStatement, nil) == SQLITE_OK else {
            return false
        }

        // The unique ID is used to find which row is to be deleted.
        sqlite3_bind_int64(deleteStatement, 1, Int64(id))

        // The statement is executed, and then finalised.
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(deleteStatement)

        return true
    }

    // Deletes all `Place` entries that are not favourites and have no `Note`s attached.
    // Returns whether the operation was successful.
    func clearUnusedPlaces() -> Bool {
        let deleteString = """
            DELETE FROM \(placesTable)
            WHERE PlaceID NOT IN (SELECT DISTINCT PlaceID FROM \(notesTable)) AND Favourite = FALSE;
        """

        // The SQL statement is prepared. No bindings are needed since the deletion condition
        // is dependent on table relations.
        var deleteStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, deleteString, -1, &deleteStatement, nil) == SQLITE_OK else {
            return false
        }

        // The statement is executed, and then finalised.
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(deleteStatement)
        return true
    }

    // Acts as a hard reset that ignores relations to the Places table and favourite status,
    // clearing the entire Places table.
    func clearAllPlaces() -> Bool {
        let deleteString = """
            DELETE FROM \(placesTable);
        """

        // The SQL statement is prepared. No bindings are needed.
        var deleteStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, deleteString, -1, &deleteStatement, nil) == SQLITE_OK else {
            return false
        }

        // The statement is executed, and then finalised.
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            return false
        }
        sqlite3_finalize(deleteStatement)
        return true
    }

    // Deletes all rows from the Notes table.
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

    // Returns all rows in the Places table each as a `Place` instance.
    // If the SQL query fails, a `nil` is returned. Otherwise, a list of Place instances is returned.
    func fetchAllPlaces() -> [Place]? {
        // The SQL Select statement fetches all rows.
        let selectString = "SELECT * FROM \(placesTable);"
        var places: [Place] = []

        // The statement is prepared.
        var selectStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, selectString, -1, &selectStatement, nil) == SQLITE_OK else {
            return nil
        }

        // The result of the query is stepped through,
        // decoding every row into a `Place` instance at each step.
        while sqlite3_step(selectStatement) == SQLITE_ROW {
            let placeId = Int(sqlite3_column_int64(selectStatement, 0))
            let name = String(cString: sqlite3_column_text(selectStatement, 1))
            let latitude = sqlite3_column_double(selectStatement, 2)
            let longitude = sqlite3_column_double(selectStatement, 3)
            // The list of categories is stored in the database as a comma-delimited string.
            let c = String(cString: sqlite3_column_text(selectStatement, 4))
            let categories = c.split(separator: ",").map { String($0) }
            // The boolean attributes are stored internally as an integer.
            let isFavourite = sqlite3_column_int(selectStatement, 5) != 0

            // The constructed `Place` instance is added to the list.
            let place = Place(
                id: placeId,
                name: name,
                latitude: latitude,
                longitude: longitude,
                categories: categories,
                isFavourite: isFavourite)
            places.append(place)
        }
        // The resources are finally freed.
        sqlite3_finalize(selectStatement)
        return places
    }

    // Returns all rows in the Notes table each as a `Note` instance.
    // If the SQL query fails, a `nil` is returned. Otherwise, a list of Place instances is returned.
    func fetchAllNotes() -> [Note]? {
        // The SQL Select statement fetches all rows.
        let selectString = "SELECT * FROM \(notesTable);"
        var notes: [Note] = []

        // The statement is prepared.
        var selectStatement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, selectString, -1, &selectStatement, nil) == SQLITE_OK else {
            return nil
        }

        // The result of the query is stepped through,
        // decoding every row into a `Note` instance at each step.
        while sqlite3_step(selectStatement) == SQLITE_ROW {
            let noteId = Int(sqlite3_column_int64(selectStatement, 0))
            let title = String(cString: sqlite3_column_text(selectStatement, 1))
            let description = String(cString: sqlite3_column_text(selectStatement, 2))
            // The `dateFormatter` is used to convert the string representation back into a date.
            // If this conversion fails, the current date is used as a fallback.
            let dateString = String(cString: sqlite3_column_text(selectStatement, 3))
            let date = dateFormatter.date(from: dateString) ?? Date()
            let placeId = Int(sqlite3_column_int64(selectStatement, 4))

            // The constructed `Note` instance is added to the list.
            let note = Note(id: noteId, title: title, description: description, date: date, placeID: placeId)
            notes.append(note)
        }
        // The resources are finally freed.
        sqlite3_finalize(selectStatement)
        return notes
    }
}
