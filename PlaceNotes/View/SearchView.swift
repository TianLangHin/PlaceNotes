//
//  SearchView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var dataStore: DataStoreViewModel
    @State var searchVM = SearchViewModel()

    @State var searchQuery = ""
    @State var isSearchingNotes = true

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Search Notes & Places")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
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
            List {
                let results = searchVM.results(searchQuery, fromNotes: isSearchingNotes, dataStore: dataStore)
                switch results {
                case .notes(let notesArray):
                    if notesArray.isEmpty {
                        Text("No notes recorded!")
                    } else {
                        ForEach(notesArray, id: \.self) { note in
                            NoteBriefView(note: note)
                                .environmentObject(dataStore)
                        }
                    }
                case .places(let placesArray):
                    if placesArray.isEmpty {
                        Text("No places recorded!")
                    } else {
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
