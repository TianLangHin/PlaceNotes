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

    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        return df
    }

    var body: some View {
        VStack {
            Text(note.title)
                .font(.title3)
                .fontWeight(.bold)
                .padding()
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
