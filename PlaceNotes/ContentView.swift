//
//  ContentView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 20/9/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dataStore = DataStoreViewModel()
    @State var placeTf = ""
    @State var noteTf = ""
    @State var placeId: Int? = nil

    var body: some View {
        Text("\(dataStore.dbManager.success)")
        Text("Selected PlaceID: \(String(describing: placeId))")
        VStack {
            List {
                Section {
                    ForEach(dataStore.fetchAllPlaces() ?? []) { place in
                        VStack {
                            Text("\(place.id) \(place.name)")
                            Text("\(place.latitude) \(place.longitude)")
                        }
                        .padding()
                    }
                } header: {
                    HStack {
                        Text("Places")
                        Spacer()
                    }
                }
            }
            List {
                Section {
                    ForEach(dataStore.fetchAllNotes() ?? []) { note in
                        VStack {
                            Text("\(note.id) \(note.title)")
                            Text("\(note.description)")
                        }
                        .padding()
                    }
                } header: {
                    HStack {
                        Text("Notes")
                        Spacer()
                    }
                }
            }
            HStack {
                VStack {
                    TextField("Place", text: $placeTf)
                    Button {
                        let place = Place(
                            id: Place.uniqueId(),
                            name: placeTf,
                            latitude: 1.0,
                            longitude: -1.0,
                            postcode: "PS",
                            categories: ["A", "B", "C"],
                            isFavourite: false
                        )
                        let s = dataStore.insertPlace(place)
                        print("Insert place: \(s)")
                    } label: {
                        Text("Add Place")
                    }
                }
                Spacer()
                VStack {
                    TextField("Note", text: $noteTf)
                    Menu("Tap Me") {
                        ForEach(dataStore.fetchAllPlaces() ?? []) { place in
                            Button {
                                placeId = place.id
                            } label: {
                                Text("\(place.name)")
                            }
                        }
                    }
                    Button {
                        if let id = placeId {
                            let note = Note(
                                id: Note.uniqueId(),
                                title: "Title",
                                description: noteTf,
                                date: Date(),
                                placeID: id)
                            let s = dataStore.insertNote(note)
                            print("Insert note: \(s)")
                        }
                    } label: {
                        Text("Add Note")
                    }
                }
            }
            .padding()
            Button {
                let a = dataStore.clearAllNotes()
                let b = dataStore.clearUnusedPlaces()
                print("Clear all: \(a)")
                print("Clear unused: \(b)")
            } label: {
                Text("Hard Reset")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
