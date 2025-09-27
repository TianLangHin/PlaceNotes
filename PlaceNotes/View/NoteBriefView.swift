//
//  NoteBriefView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 26/9/2025.
//

import SwiftUI

struct NoteBriefView: View {
    @EnvironmentObject var dataStore: DataStoreViewModel
    @State var note: Note
    @State var showPlace: Bool = true

    @State var isShowingSheet = false

    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        return df
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(note.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Image(systemName: "pencil.line")
                }
            }
            HStack {
                if showPlace {
                    let place = dataStore.getPlace(by: note.placeID)
                    if let attachedPlace = place {
                        Text("Note for: \(attachedPlace.name)")
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Text(dateFormatter.string(from: note.date))
                } else {
                    Spacer()
                    Text(dateFormatter.string(from: note.date))
                    Spacer()
                }
            }
            Text(note.description)
                .padding()
        }
        .sheet(isPresented: $isShowingSheet, onDismiss: {
            if let newNote = dataStore.getNote(by: note.id) {
                note = newNote
            }
        }) {
            EditNoteView(note: note, attachedPlace: dataStore.getPlace(by: note.placeID))
        }
    }
}

#Preview {
    List {
        NoteBriefView(note: Note(
            id: 1000,
            title: "Pick up groceries",
            description: "Here is a grocery list. Tomatoes, potatoes, carrots, eggs, toilet paper, milk, butter.",
            date: Date(),
            placeID: 1))
        .environmentObject(DataStoreViewModel())
    }
}
