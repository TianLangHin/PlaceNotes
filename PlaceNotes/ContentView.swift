//
//  ContentView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 20/9/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dataStore = DataStoreViewModel()
    @State var placeTf = ""
    @State var noteTf = ""
    @State var placeId: Int? = nil

    var body: some View {
        TabView {
            MapExploreView()
                .environmentObject(dataStore)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }

            VStack {
                Text("\(dataStore.dbManager.success)")
                Text("Selected PlaceID: \(String(describing: placeId))")
                Spacer()
                Text("Places")
                List {
                    ForEach(dataStore.places) { place in
                        Text("\(place.name)")
                    }
                }
                Text("Notes")
                List {
                    ForEach(dataStore.notes) { note in
                        Text("\(note.title) \(note.description)")
                    }
                }
                Button {
                    dataStore.completeReset()
                } label: {
                    Text("Hard Reset")
                }
            }
            .padding()
            .tabItem {
                Image(systemName: "clock.fill")
                Text("DB Manager")
            }
        }
    }
}

#Preview {
    ContentView()
}
