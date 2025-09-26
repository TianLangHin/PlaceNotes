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

    let dateFormatter = DateFormatter.iso()

    var body: some View {
        VStack {
            HStack {
                Text(dateFormatter.string(from: note.date))
                Spacer()
                Text(note.title)
                    .fontWeight(.bold)
                Spacer()
            }
            let place = dataStore.getPlace(by: note.placeID)
            if let attachedPlace = place {
                Text("Note for: \(attachedPlace.name)")
                    .fontWeight(.bold)
            }
            Text(note.description)
        }
    }
}
