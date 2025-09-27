//
//  SearchViewModel.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

@Observable
class SearchViewModel {
    enum SearchResult {
        case notes([Note])
        case places([Place])
    }

    func results(_ query: String, fromNotes: Bool, dataStore: DataStoreViewModel) -> SearchResult {
        let queryString = query.trimmingCharacters(in: .whitespaces).lowercased()
        if fromNotes {
            if queryString == "" {
                return .notes(dataStore.notes)
            } else {
                let matchingNotes = dataStore.notes.filter { note in
                    let matchesTitle = note.title.lowercased().contains(queryString)
                    let matchesDesc = note.description.lowercased().contains(queryString)
                    return matchesTitle || matchesDesc
                }
                return .notes(matchingNotes)
            }
        } else {
            if queryString == "" {
                return .places(dataStore.places)
            } else {
                let matchingPlaces = dataStore.places.filter { place in
                    return place.name.lowercased().contains(queryString)
                }
                return .places(matchingPlaces)
            }
        }
    }
}
