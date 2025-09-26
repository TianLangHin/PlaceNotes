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
            RankedNotesView()
                .environmentObject(dataStore)
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notes")
                }
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
                    Text("Debug")
                }
        }
    }
}

#Preview {
    ContentView()
}
