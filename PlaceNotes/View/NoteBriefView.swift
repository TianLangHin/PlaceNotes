//
//  NoteBriefView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 26/9/2025.
//

import SwiftUI

/// This View is not intended to be displayed on its own as a page,
/// but rather as an element in a List that will pop up a sheet
/// to a view that allows editing of the `Note`.
struct NoteBriefView: View {
    // Since this View will need to provide database manipulation operations
    // to the child Views that pop up via a sheet, it needs access to
    // the `DataStoreViewModel` as an EnvironmentObject as well.
    @EnvironmentObject var dataStore: DataStoreViewModel

    // This View needs a reference to the `Note` it is representing,
    // and an indicator of whether the summary it shows should include
    // the associated place or not.
    @State var note: Note
    @State var showPlace: Bool

    // State variable to control whether the sheet pop up is open or not.
    @State var isShowingSheet = false

    // A date formatter used to display each note's set date,
    // in an intuitive human readable format.
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        // This format shows the month in abbreviated form (e.g., "26 Sep 2025").
        df.dateFormat = "dd MMM yyyy"
        return df
    }

    var body: some View {
        VStack {
            // The title is bolded and centred, showing the note title.
            HStack {
                Spacer()
                Text(note.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                // On the right is a pencil icon,
                // which will pop up the editing view when tapped.
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Image(systemName: "pencil.line")
                }
            }
            // The next layer shows the date in the centre
            // if the attached place does not need to be displayed.
            // Otherwise, it displays the attached place in bold on the left,
            // and the date on the right.
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
            // Finally, the description text of the note is shown below the headers.
            Text(note.description)
                .padding()
        }
        .sheet(isPresented: $isShowingSheet, onDismiss: {
            // This on-dismiss callback ensures that the displayed content
            // will always be up to date even when the child
            // `EditNoteView` modifies the Note.
            if let newNote = dataStore.getNote(by: note.id) {
                note = newNote
            }
        }) {
            // When the edit icon is clicked, the `EditNoteView` will pop up via a sheet,
            // allowing the user to edit it from any view that displays the
            // brief note view to maximise convenient.
            EditNoteView(note: note, attachedPlace: dataStore.getPlace(by: note.placeID))
                .environmentObject(dataStore)
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
            placeID: 1), showPlace: false)
        .environmentObject(DataStoreViewModel())
    }
}
