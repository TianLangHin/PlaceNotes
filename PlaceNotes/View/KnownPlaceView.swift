//
//  KnownPlaceView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 26/9/2025.
//

import SwiftUI

/// This view will pop up when a `Marker` that corresponds with a known place inside the map
/// (i.e., a `Place` that is attached to by some existing `Note`) is tapped.
/// It provides functionalities of adding, editing and removing attached notes,
/// and toggling the favourite status of the `Place`.
struct KnownPlaceView: View {
    // This View comes with a dismiss function, hence the `dismiss` environment modifier is needed.
    @Environment(\.dismiss) var dismiss

    // This View will permit operations that add, edit, or modify persistently stored data,
    // so the `DataStoreViewModel` is required.
    @EnvironmentObject var dataStore: DataStoreViewModel

    // The `CategoriesViewModel` instance provides a way to show the associated categories
    // (in the `categories` property) relating to the `Place` instance in a user-friendly way.
    // It is defined using the `@Observable` modifier as per iOS 17+, hence `@State` is used here.
    @State var converter = CategoriesViewModel()

    // The `Place` instance being edited must be passed as an argument.
    @State var place: Place

    // A boolean state variable that can be toggled to control the favourite status of `place`.
    @State var isFavourite = false

    // State variables that control pop ups (for `EditNoteView`) and alerts (when DB operations fail).
    @State var isShowingSheet = false
    @State var isAlerting = false
    @State var alertText = ""

    var body: some View {
        VStack(alignment: .center) {
            // The name of the `Place` is put in large and bold font,
            // with the favourite toggling button next to it.
            HStack {
                Text(place.name)
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
                // The toggle favourite button immediately updates the data store and
                // may dismiss the View immediately, hence it is abstracted into a sub-view.
                toggleFavouriteButton()
                    .foregroundStyle(.red)
            }
            // Right below the title, the categories associated with the `Place` instance
            // are listed in a horizontally scrollable series of capsules
            // to provide a more user-friendly method of viewing the list.
            // It also emphasises the separation between each item in a readable way.
            HStack {
                Spacer()
                Text("Categories")
                    .fontWeight(.bold)
                    .font(.title3)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    ForEach(converter.categoryNames(place.categories), id: \.self) { category in
                        // The capsules are not tappable, hence they are not filled in
                        // to ensure they do not look like buttons.
                        Text(category)
                            .padding()
                            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding()
            }
            // Next, all the notes attached to this particular `Place` are listed.
            // To retrieve all such relevant notes, the list of all notes
            // is filtered on whether the associated `placeID` matches the `id` of the current `Place`.
            let relevantNotes = dataStore.notes.filter { note in
                note.placeID == place.id
            }
            Text("Existing Notes: \(relevantNotes.count)")
                .fontWeight(.bold)
                .font(.title3)
            List {
                if relevantNotes.isEmpty {
                    // A placeholder is put here if there are no relevant notes,
                    // to visually signal to the user that the app has not failed.
                    Text("No existing notes!")
                } else {
                    // Each of the notes are listed using the `NoteBriefView`.
                    // This way, tapping on a view allows the user to edit it (in a pop-up sheet),
                    // while the item can be swiped to delete.
                    ForEach(relevantNotes, id: \.self) { note in
                        // Since all `Note`s in this View are associated with the same `Place`,
                        // there is no need to display it in this list.
                        NoteBriefView(note: note, showPlace: false)
                            .environmentObject(dataStore)
                    }
                    .onDelete { indexSet in
                        // Upon swipe, a particular `indexSet` is indicated to be removed.
                        for index in indexSet {
                            // All indices in the set are iterated over,
                            // and every such row in the Notes table is removed from the SQLite database.
                            let _ = dataStore.deleteNote(by: relevantNotes[index].id)
                        }
                        // This app will only store a `Place` if there is a `Note` that references it.
                        // Hence, this invariant is maintained here after deleting the notes.
                        let _ = dataStore.clearUnusedPlaces()
                        // As a result, if the deletion operation makes it so that this Place
                        // should no longer be stored, the view is dismissed immediately.
                        // This ensures that the user cannot edit an invalid or non-existent `Place`.
                        let noMoreNotes = dataStore.notes.allSatisfy { note in note.placeID != place.id }
                        if !isFavourite && noMoreNotes {
                            dismiss()
                        }
                    }
                }
            }
            .padding()
            // Finally, this button allows the user to add a new note attached to this `Place`.
            // This is done by popping up a sheet to a `NewNoteView`.
            HStack {
                Spacer()
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Text("Add New Note")
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $isShowingSheet) {
            // The `NewNoteView` needs a reference to which (known) Place it is attached to.
            NewNoteView(attachedLocation: .place(place))
                .environmentObject(dataStore)
        }
        .onAppear {
            // Upon View creation, the `isFavourite` state variable
            // is synchronised with that of the internal data.
            isFavourite = place.isFavourite
        }
        .alert(alertText, isPresented: $isAlerting) {
            // A generic alert format, where the alert text is determined by the problem encountered.
            Button("OK", role: .cancel) {}
        }
    }

    // The component of the view that implements the button which toggles the favourite status.
    func toggleFavouriteButton() -> some View {
        Button {
            // Firstly, the View's state is updated.
            isFavourite.toggle()

            // The new (adjusted) Place instance is created, with the same properties
            // except for the new favourite status.
            let toggledPlace = Place(
                id: place.id,
                name: place.name,
                latitude: place.latitude,
                longitude: place.longitude,
                categories: place.categories,
                isFavourite: isFavourite)
            // The persistent storage is then updated, which should replace the value in the same original row.
            let updateSuccess = dataStore.updatePlace(toggledPlace)
            if !updateSuccess {
                // If the database encountered an irrecoverable error, the user is notified
                // so that they do not expect it to work when it has failed internally.
                alertText = "Could not toggle the favourite status! Please try again later."
                isAlerting = true
            } else {
                // Checks whether this modification makes it so that the place will no longer be recorded.
                // If it will disappear, then immediately dismiss the view so no invalid operations can happen.
                let _ = dataStore.clearUnusedPlaces()
                let noMoreNotes = dataStore.notes.allSatisfy { note in note.placeID != place.id }
                if !isFavourite && noMoreNotes {
                    dismiss()
                }
            }
        } label: {
            // The content of the button will indicate the favourite status.
            Image(systemName: "heart" + (isFavourite ? ".fill" : ""))
        }
    }
}
