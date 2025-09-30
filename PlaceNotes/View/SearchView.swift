//
//  SearchView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

/// The third view that the user will see in the app.
/// While `MapExploreView` is the main functionality of the app
/// to visualise the distribution of one's notes,
/// this allows a more conventional form of searching through the notes
/// in case there are too many to visualise at once.
struct SearchView: View {
    // This View will contain both `NoteBriefView` and `PlaceBriefView` instances,
    // both of which need access to the `DataStoreViewModel`. Hence, it is brought here as well.
    @EnvironmentObject var dataStore: DataStoreViewModel

    // The searching functionality is also provided by the `SearchViewModel`,
    // abstracting the implementation details away from the UI setup of this view.
    @State var searchVM = SearchViewModel()

    // State variables to keep track of the string searched by the user
    // and whether they are looking for a Note or a Place.
    @State var searchQuery = ""
    @State var isSearchingNotes = true

    var body: some View {
        VStack {
            // The title is in a large font and bolded at the top of the View.
            HStack {
                Spacer()
                Text("Search Notes & Places")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            // To the left of the text field for the query keyword
            // is a button that toggles whether the user is searching for Notes or Places.
            HStack {
                Button {
                    isSearchingNotes.toggle()
                } label: {
                    Text(isSearchingNotes ? "Notes" : "Places")
                }
                .buttonStyle(.bordered)
                Spacer()
                TextField("Search query here...", text: $searchQuery)
            }
            .padding()
            // The `SearchViewModel` instance provides a `results` function
            // that returns either Notes or Places that match a given query.
            // The stored
            List {
                let results = searchVM.results(searchQuery, fromNotes: isSearchingNotes, dataStore: dataStore)
                // The `searchVM.results` function will return an enum variant
                // that either contains a list of Notes or a list of Places.
                switch results {
                case .notes(let notesArray):
                    if notesArray.isEmpty {
                        // In the list of Notes case, the placeholder signifies this accordingly.
                        Text("No notes recorded!")
                    } else {
                        // If the list is not empty in this case,
                        // each array element corresponds to a `NoteBriefView`, and is passed the environment object.
                        ForEach(notesArray, id: \.self) { note in
                            NoteBriefView(note: note, showPlace: true)
                                .environmentObject(dataStore)
                        }
                    }
                case .places(let placesArray):
                    if placesArray.isEmpty {
                        // In the list of Places case, the placeholder signifies this accordingly.
                        Text("No places recorded!")
                    } else {
                        // If the list is not empty in this case,
                        // each array element corresponds to a `PlaceBriefView`, and is passed the environment object.
                        ForEach(placesArray, id: \.self) { place in
                            PlaceBriefView(place: place)
                                .environmentObject(dataStore)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
