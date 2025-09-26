//
//  RankedNotesView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

struct RankedNotesView: View {
    @EnvironmentObject var dataStore: DataStoreViewModel

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Your Notes")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            List {
                if dataStore.notes.isEmpty {
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            Text("No notes yet!")
                            Text("Go to the Map to start adding some!")
                        }
                        Spacer()
                    }
                } else {
                    let rankedNotes = dataStore.notes.sorted(by: { note1, note2 in
                        note1.date < note2.date
                    })
                    Section {
                        ForEach(rankedNotes.filter { $0.date < Date() }) { note in
                            NoteBriefView(note: note)
                                .environmentObject(dataStore)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let _ = dataStore.deleteNote(by: rankedNotes[index].id)
                            }
                            let _ = dataStore.clearUnusedPlaces()
                        }
                    } header: {
                        HStack {
                            Spacer()
                            Text("Notes from before today")
                            Spacer()
                        }
                    }
                    Section {
                        ForEach(rankedNotes.filter { $0.date >= Date() }) { note in
                            NoteBriefView(note: note)
                                .environmentObject(dataStore)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let _ = dataStore.deleteNote(by: rankedNotes[index].id)
                            }
                            let _ = dataStore.clearUnusedPlaces()
                        }
                    } header: {
                        HStack {
                            Spacer()
                            Text("Notes for today or later")
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}
