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

    @State var isAlerting = false
    @State var alertText = ""

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("New Note for \(attachedLocation.name)")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
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
                Spacer()
            }
            .padding()
            Spacer()
        }
        .alert(alertText, isPresented: $isAlerting) {
            Button("OK", role: .cancel) {}
        }
    }

    func saveNote() {
        switch attachedLocation {
        case let .place(knownPlace):
            let newNote = Note(
                id: Note.uniqueId(),
                title: titleText,
                description: descriptionText,
                date: date,
                placeID: knownPlace.id)
            let addNoteSuccess = dataStore.addNote(newNote)
            if !addNoteSuccess {
                alertText = "Sorry, this note could not be added. Please try again later!"
                isAlerting = true
            }
        case let .location(newLocation):
            let newPlace = Place(
                id: Place.uniqueId(),
                name: newLocation.name,
                latitude: newLocation.latitude,
                longitude: newLocation.longitude,
                categories: newLocation.categories,
                isFavourite: false)
            let addPlaceSuccess = dataStore.addPlace(newPlace)
            if !addPlaceSuccess {
                alertText = "Sorry, this note could not be added. Please try again later!"
                isAlerting = true
            }
            let newNote = Note(
                id: Note.uniqueId(),
                title: titleText,
                description: descriptionText,
                date: date,
                placeID: newPlace.id)
            let addNoteSuccess = dataStore.addNote(newNote)
            if !addNoteSuccess {
                alertText = "Sorry, this note could not be added. Please try again later!"
                isAlerting = true
            }
        }
    }
}

#Preview {
    NewNoteView(
        attachedLocation: .location(LocationData(
            name: "Place Name",
            categories: [],
            latitude: 100,
            longitude: -100,
            country: "Australia")))
}
