//
//  NewNoteView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 24/9/2025.
//

import SwiftUI

/// This View will appear in one of two situations:
/// 1. The user has tapped on an orange marker in `MapExploreView`.
/// 2. The user has tapped the "Add Note" button in `KnownPlaceView`.
/// The user can enter information to record a new note, and stores it upon dismissal.
struct NewNoteView: View {
    // This view will need to dismiss itself upon saving,
    // hence the "dismiss" environment modifier is needed.
    @Environment(\.dismiss) var dismiss

    // This View will create a new Note and store it in the database,
    // as well as potentially a new Place for the first time.
    // Hence, it needs access to the persistent storage manager `DataStoreViewModel`.
    @EnvironmentObject var dataStore: DataStoreViewModel

    // The `CategoriesViewModel` instance provides a way to show the associated categories
    // in a user friendly manner.
    @State var converter = CategoriesViewModel()

    // The `MapPoint` enum either contains a `Place` or a `LocationData` instance.
    // This will affect its behaviour of whether to create a new row in the Place table.
    @State var attachedLocation: MapPoint

    // These correspond directly to information that must be stored as part of a `Note`.
    @State var titleText = ""
    @State var descriptionText = ""
    @State var date = Date.now

    // These state variables control the status of the alert pop up.
    @State var isAlerting = false
    @State var alertText = ""

    var body: some View {
        VStack {
            // The associated location for the note is displayed for the user at the top,
            // as that is the only certain piece of information currently.
            HStack {
                Spacer()
                Text("New Note for \(attachedLocation.name)")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
                Spacer()
            }

            // The list of categories associated with the attached location
            // is displayed as a horizontally scrollable list just under the title.
            HStack {
                Spacer()
                Text("Categories")
                    .fontWeight(.bold)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    // The display text of each category is determined
                    // by the `CategoryViewModel` to be more human-readable.
                    let categories = converter.categoryNames(attachedLocation.categories)
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .padding()
                            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
                        // Each capsule is not filled, indicating it is not clickable.
                    }
                }
                .padding()
            }

            // Firstly, the note title can be added.
            HStack {
                Text("Note Title")
                    .fontWeight(.bold)
                    .font(.title3)
                    .padding()
                TextField("Enter note title here...", text: $titleText)
            }
            .padding()

            // Under it, the full note description can be added.
            // To indicate that a larger length of text can be added,
            // a larger TextField with a clear border is given.
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

            // Finally, the user can also set the date for which the note is relevant.
            DatePicker("Reminder For:", selection: $date)
                .padding()

            // At the bottom of the View, near where the thumb would rest,
            // the button saves the changes made to the note and dismisses the View.
            HStack {
                Spacer()
                Button {
                    let trimmedTitle = titleText.trimmingCharacters(in: .whitespaces)
                    let trimmedDesc = descriptionText.trimmingCharacters(in: .whitespaces)
                    // The button will only save the note if the
                    // title and description are not blank (ignoring whitespace).
                    if trimmedTitle != "" && trimmedDesc != "" {
                        saveNote()
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
            // Any alert in this view is a result of a database update failure.
            // In such cases, the view should be dismissed when the alert is dismissed.
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
    }

    /// The function to be called as the final action in this view.
    /// It will dismiss the view if the database updates are successful.
    func saveNote() {
        switch attachedLocation {
        case let .place(knownPlace):
            // If the attached location is known (an existing row in the Places table),
            // then only the new Note is being inserted into the database.

            // The new `Note` is constructed with a newly generated unique `Note` ID.
            let newNote = Note(
                id: Note.uniqueId(),
                title: titleText,
                description: descriptionText,
                date: date,
                placeID: knownPlace.id)
            let addNoteSuccess = dataStore.addNote(newNote)
            if !addNoteSuccess {
                // If the operation failed, however, an alert is made.
                alertText = "Sorry, this note could not be added. Please try again later!"
                isAlerting = true
            }
        case let .location(newLocation):
            // If the attached location is a new one, then the new Place
            // must be added to the Places table before the new Note is added.

            // The new `Place` is constructed with the default favourite status as false.
            // It is also constructed with a newly generated unique `Place` ID.
            let newPlace = Place(
                id: Place.uniqueId(),
                name: newLocation.name,
                latitude: newLocation.latitude,
                longitude: newLocation.longitude,
                categories: newLocation.categories,
                isFavourite: false)
            let addPlaceSuccess = dataStore.addPlace(newPlace)
            if !addPlaceSuccess {
                // If the operation of adding the Place failed, an alert is made.
                alertText = "Sorry, this location could not be added. Please try again later!"
                isAlerting = true
            } else {
                // The new `Note` is constructed with a newly generated unique `Note` ID.
                let newNote = Note(
                    id: Note.uniqueId(),
                    title: titleText,
                    description: descriptionText,
                    date: date,
                    placeID: newPlace.id)
                let addNoteSuccess = dataStore.addNote(newNote)
                if !addNoteSuccess {
                    // If the operation of adding the Note failed, an alert is made.
                    alertText = "Sorry, this note could not be added. Please try again later!"
                    isAlerting = true
                }
            }
        }
        if !isAlerting {
            // If the operations were successful,
            // the "Save Note" button should dismiss the View.
            // Otherwise, that happens when the alert is dismissed.
            dismiss()
        }
    }
}

#Preview {
    NewNoteView(
        attachedLocation: .location(LocationData(
            name: "Place Name",
            categories: ["entertainment.activity_park", "airport.international", "commercial.outdoor_and_sport"],
            latitude: 100,
            longitude: -100,
            country: "Australia")))
}
