//
//  AllNotesView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 26/9/2025.
//

import SwiftUI

struct AllNotesView: View {
    @EnvironmentObject var dataStore: DataStoreViewModel

    var body: some View {
        VStack {
            Text("\(dataStore.dbManager.success)")
            Spacer()
            Text("Places")
            List {
                ForEach(dataStore.places) { place in
                    Text("\(place.id): \(place.name) (\(place.isFavourite))")
                }
            }
            Text("Notes")
            List {
                ForEach(dataStore.notes) { note in
                    VStack {
                        Text("\(note.title) \(note.description)")
                        HStack {
                            Spacer()
                            Text("\(note.placeID)")
                            Spacer()
                        }
                    }
                }
            }
            Button {
                dataStore.completeReset()
            } label: {
                Text("Hard Reset")
            }
        }
        .padding()
    }
}
