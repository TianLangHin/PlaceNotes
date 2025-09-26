//
//  ContentView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 20/9/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dataStore = DataStoreViewModel()

    var body: some View {
        TabView {
            MapExploreView()
                .environmentObject(dataStore)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            AllNotesView()
                .environmentObject(dataStore)
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Notes")
                }
        }
    }
}

#Preview {
    ContentView()
}
