//
//  KnownPlaceView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 26/9/2025.
//

import SwiftUI

struct KnownPlaceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: DataStoreViewModel

    @State var place: Place

    @State var titleText = ""
    @State var descriptionText = ""
    @State var date = Date()

    @State var isFavourite = false
    @State var isShowingSheet = false

    @State var isAlerting = false
    @State var alertText = ""

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text(place.name)
                    .fontWeight(.bold)
                    .font(.title)
                    .padding()
                toggleFavouriteButton()
            }
            let relevantNotes = dataStore.notes.filter { note in
                note.placeID == place.id
            }
            Text("Existing Notes: \(relevantNotes.count)")
                .fontWeight(.bold)
                .font(.title3)
            List {
                if relevantNotes.isEmpty {
                    Text("No existing notes!")
                } else {
                    ForEach(relevantNotes) { note in
                        NoteBriefView(note: note, showPlace: false)
                            .environmentObject(dataStore)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let _ = dataStore.deleteNote(by: relevantNotes[index].id)
                        }
                        let _ = dataStore.clearUnusedPlaces()
                        let noMoreNotes = dataStore.notes.allSatisfy { note in note.placeID != place.id }
                        if !isFavourite && noMoreNotes {
                            dismiss()
                        }
                    }
                }
            }
            .padding()
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
            NewNoteView(attachedLocation: .place(place))
                .environmentObject(dataStore)
        }
        .onAppear {
            isFavourite = place.isFavourite
        }
        .alert(alertText, isPresented: $isAlerting) {
            Button("OK", role: .cancel) {}
        }
    }

    func toggleFavouriteButton() -> some View {
        Button {
            isFavourite.toggle()
            let toggledPlace = Place(
                id: place.id,
                name: place.name,
                latitude: place.latitude,
                longitude: place.longitude,
                categories: place.categories,
                isFavourite: isFavourite)
            let updateSuccess = dataStore.updatePlace(toggledPlace)
            if !updateSuccess {
                alertText = "Could not toggle the favourite status! Please try again later."
                isAlerting = true
            }
            let noMoreNotes = dataStore.notes.allSatisfy { note in note.placeID != place.id }
            if !isFavourite && noMoreNotes {
                let _ = dataStore.clearUnusedPlaces()
                dismiss()
            }
        } label: {
            Image(systemName: "heart" + (isFavourite ? ".fill" : ""))
        }
    }
}
