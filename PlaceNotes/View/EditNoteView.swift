//
//  EditNoteView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

/// This View will pop up when a `NoteBriefView` is tapped,
/// allowing the user to edit the contents of a note (while preserving its ID).
struct EditNoteView: View {
    // This View comes with a dismiss function, hence the `dismiss` environment modifier is needed.
    @Environment(\.dismiss) var dismiss

    // Since this edits a note stored in the persistent database,
    // this view also needs access to the `DataStoreViewModel` environment object.
    @EnvironmentObject var dataStore: DataStoreViewModel

    // The arguments passed to this view include both the `Note` being edited and the place it references.
    // This is optional to account for the possibility that the primary key reference fails.
    @State var note: Note
    @State var attachedPlace: Place?

    // These internal state variables contain the fields within the note that can be edited.
    @State var titleText = ""
    @State var descriptionText = ""
    @State var date = Date()

    // The variable controlling whether an alert (from an internal database error) needs to be displayed.
    @State var isAlerting = false

    var body: some View {
        VStack {
            // Title shows which place the note is attached to,
            // so the user knows if the right note is being edited.
            HStack {
                Spacer()
                Text("Editing Note for \(attachedPlace?.name ?? "")")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
                Spacer()
            }

            // The title of the note is editable through the `titleText` state binded to the TextField.
            HStack {
                Text("Note Title")
                    .fontWeight(.bold)
                    .font(.title3)
                    .padding()
                TextField("Enter note title here...", text: $titleText)
            }
            .padding()

            // The long description of the note is editable through a larger TextField with several lines
            // available. A strong border is also used to display exactly where to start typing from.
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

            // The date of the note is editable through the iOS date picking interface.
            DatePicker("Reminder For:", selection: $date)
                .padding()

            // At the bottom of the View, near where the thumb would rest,
            // the button saves the changes made to the note and dismisses the View.
            HStack {
                Spacer()
                Button {
                    let trimmedTitle = titleText.trimmingCharacters(in: .whitespaces)
                    let trimmedDesc = descriptionText.trimmingCharacters(in: .whitespaces)
                    // The button will only save the note if the title and description are not blank (ignoring whitespace).
                    if trimmedTitle != "" && trimmedDesc != "" {
                        saveChanges()
                    }
                } label: {
                    Text("Save Note")
                }
                Spacer()
            }
            .padding()

            // The spacing at the bottom ensure that all elements are stacked downwards from the top of the screen.
            Spacer()
        }
        .onAppear {
            // When the View is created, the internal state variables need to be synchronised.
            titleText = note.title
            descriptionText = note.description
            date = note.date
        }
        .alert("Sorry, note could not be edited! Please try again later.", isPresented: $isAlerting) {
            // This alert will appear if the `DataStoreViewModel` encounters an error when attempting to save the new Note.
            Button("OK", role: .cancel) {
                // Once the user dismisses the alert, dismiss the entire view.
                dismiss()
            }
        }
    }

    func saveChanges() {
        // The new Note instance is constructed from the new values, with the same primary key.
        let newNoteValue = Note(id: note.id, title: titleText, description: descriptionText, date: date, placeID: note.placeID)
        // Then, update the persistent data storage manager with the new Note.
        let success = dataStore.updateNote(newNoteValue)
        if !success {
            // If it failed, do not dismiss the view yet, and pop up the alert.
            isAlerting = true
        } else {
            // If successful, dismiss the view immediately.
            dismiss()
        }
    }
}
