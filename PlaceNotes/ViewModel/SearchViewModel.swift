//
//  SearchViewModel.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

/// This ViewModel handles the logic of searching through either the list of notes or places
/// in the persistent storage. It returns either a list of notes or a list of places,
/// hence the `SearchResult` enum is made to represent a union type in this situation.
@Observable
class SearchViewModel {
    // For convenicence in the UI, only one function is used for returning results.
    // Hence, either a list of notes or places will be returned. The enum variants represent these possibilities.
    enum SearchResult {
        case notes([Note])
        case places([Place])
    }

    /// While this ViewModel does not store a reference to the persistent database itself,
    /// it requires access to it temporarily during the fetching of results.
    /// The `fromNotes` argument causes the function to return `.notes` if true or `.places` if false.
    func results(_ query: String, fromNotes: Bool, dataStore: DataStoreViewModel) -> SearchResult {
        // To account for varying capitalisation of letters, all string matching is done in lowercase.
        let queryString = query.trimmingCharacters(in: .whitespaces).lowercased()
        if fromNotes {
            // An empty query means that nothing was put in the search box.
            // In such cases, no filter should be applied and all notes are to be returned.
            if queryString == "" {
                return .notes(dataStore.notes)
            } else {
                let matchingNotes = dataStore.notes.filter { note in
                    // For notes, search for matches in both the title and the description.
                    let matchesTitle = note.title.lowercased().contains(queryString)
                    let matchesDesc = note.description.lowercased().contains(queryString)
                    return matchesTitle || matchesDesc
                }
                return .notes(matchingNotes)
            }
        } else {
            // An empty query means that nothing was put in the search box.
            // In such cases, no filter should be applied and all places are to be returned.
            if queryString == "" {
                return .places(dataStore.places)
            } else {
                let matchingPlaces = dataStore.places.filter { place in
                    // For places, search for matches in the name.
                    return place.name.lowercased().contains(queryString)
                }
                return .places(matchingPlaces)
            }
        }
    }
}
