//
//  RankedNotesView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

/// This is the first View that the user will see when opening the app,
/// showing the chronological order of all the stored notes according to their set date.
/// It also divides the notes into ones with dates before the current date and after.
///
/// This view also allows the modification of these notes, including editing and deleting.
struct RankedNotesView: View {
    // Since this View will facilitate the manipulation of the Notes table,
    // it needs access to the ViewModel handling persistent storage.
    @EnvironmentObject var dataStore: DataStoreViewModel

    var body: some View {
        VStack {
            // The large bolded title up the top makes the purpose of this view clear.
            HStack {
                Spacer()
                Text("Your Notes")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            List {
                if dataStore.notes.isEmpty {
                    // A placeholder for when there are no notes in the Notes table,
                    // ensuring the user that the app has not malfunctioned or frozen.
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            Text("No notes yet!")
                            Text("Go to the Map to start adding some!")
                        }
                        Spacer()
                    }
                } else {
                    // Otherwise, the notes are ranked in chronological order on the `date` proeprty.
                    let rankedNotes = dataStore.notes.sorted(by: { note1, note2 in
                        note1.date < note2.date
                    })
                    // The first section contains the notes with dates before the current time.
                    Section {
                        ForEach(rankedNotes.filter { $0.date < Date() }, id: \.self) { note in
                            // Each item in the list contains the brief view that can
                            // open up to the full view that allows editing.
                            NoteBriefView(note: note, showPlace: true)
                                .environmentObject(dataStore)
                        }
                        .onDelete { indexSet in
                            // The on-delete behaviour allows the swiping of an item
                            // to remove the corresponding Note from the database.
                            for index in indexSet {
                                let _ = dataStore.deleteNote(by: rankedNotes[index].id)
                            }
                            let _ = dataStore.clearUnusedPlaces()
                        }
                    } header: {
                        // An indicator of the notes' dates relative to the current date.
                        HStack {
                            Spacer()
                            Text("Notes from before today")
                            Spacer()
                        }
                    }
                    // The second section contains the notes with dates on or after the current time.
                    Section {
                        ForEach(rankedNotes.filter { $0.date >= Date() }, id: \.self) { note in
                            // Each item in the list contains the brief view that can
                            // open up to the full view that allows editing.
                            NoteBriefView(note: note, showPlace: true)
                                .environmentObject(dataStore)
                        }
                        .onDelete { indexSet in
                            // The on-delete behaviour allows the swiping of an item
                            // to remove the corresponding Note from the database.
                            for index in indexSet {
                                let _ = dataStore.deleteNote(by: rankedNotes[index].id)
                            }
                            let _ = dataStore.clearUnusedPlaces()
                        }
                    } header: {
                        // An indicator of the notes' dates relative to the current date.
                        HStack {
                            Spacer()
                            Text("Notes for today or later")
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.inset) // This makes the section headers in the list more visible.
            .onAppear {
                // This ensures that upon loading of this View, the shown data is up to date.
                dataStore.refresh()
            }
        }
    }
}
