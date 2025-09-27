//
//  EditNoteView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

struct EditNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStoreViewModel

    @State var note: Note
    @State var attachedPlace: Place?

    @State var titleText = ""
    @State var descriptionText = ""
    @State var date = Date()

    @State var isAlerting = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Editing Note for \(attachedPlace?.name ?? "")")
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
                        saveChanges()
                    }
                } label: {
                    Text("Save Note")
                }
                Spacer()
            }
            .padding()
            Spacer()
        }
        .onAppear {
            titleText = note.title
            descriptionText = note.description
            date = note.date
        }
        .alert("Sorry, note could not be edited! Please try again later.", isPresented: $isAlerting) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
    }

    func saveChanges() {
        let newNoteValue = Note(id: note.id, title: titleText, description: descriptionText, date: date, placeID: note.placeID)
        let success = dataStore.updateNote(newNoteValue)
        if !success {
            isAlerting = true
        } else {
            dismiss()
        }
    }
}
