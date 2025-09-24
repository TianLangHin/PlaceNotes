//
//  NewNoteView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 24/9/2025.
//

import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStoreViewModel

    @State var attachedLocation: MapPoint

    @State var titleText = ""
    @State var descriptionText = ""
    @State var date = Date()

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text("New Note")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                    switch attachedLocation {
                    case .place(let place):
                        Text("For: \(place.name)")
                    case .location(let locationData):
                        Text("For: \(locationData.name)")
                    }
                }
                Spacer()
            }
            HStack {
                Text("Note Title")
                    .fontWeight(.bold)
                    .font(.title3)
                    .padding()
                TextField("Enter note title here...", text: $titleText)
            }
            .padding()
            HStack {
                Spacer()
                Text("Note Description")
                    .fontWeight(.bold)
                    .font(.title3)
                Spacer()
            }
            TextField("Enter note description here...", text: $descriptionText, axis: .vertical)
                .lineLimit(5...10)
                .padding()
                .border(.black)
                .padding()
            DatePicker("Reminder For:", selection: $date)
                .padding()
            HStack {
                Spacer()
                Button {
                    let trimmedTitle = titleText.trimmingCharacters(in: .whitespaces)
                    let trimmedDesc = descriptionText.trimmingCharacters(in: .whitespaces)
                    if trimmedTitle != "" && trimmedDesc != "" {
                        saveNote()
                        dismiss()
                    }
                } label: {
                    Text("Save Note")
                }
            }
            .padding()
            Spacer()
        }
    }

    func saveNote() {
        switch attachedLocation {
        case let .place(place):
            let newNote = Note(
                id: Note.uniqueId(),
                title: titleText,
                description: descriptionText,
                date: date,
                placeID: place.id)
            let _ = dataStore.addNote(newNote)
        case let .location(locationData):
            let newPlace = Place(
                id: Place.uniqueId(),
                name: locationData.name,
                latitude: locationData.latitude,
                longitude: locationData.longitude,
                categories: locationData.categories,
                isFavourite: false)
            let _ = dataStore.addPlace(newPlace)
            let newNote = Note(
                id: Note.uniqueId(),
                title: titleText,
                description: descriptionText,
                date: date,
                placeID: newPlace.id)
            let _ = dataStore.addNote(newNote)
        }
    }
}

#Preview {
    NewNoteView(attachedLocation: .location(LocationData(name: "Place Name", categories: [], latitude: 100, longitude: -100, country: "Australia")))
}
