//
//  ContentView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 20/9/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dataStore = DataStoreViewModel()
    @ObservedObject var mapViewModel = MapViewModel()

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
                .environmentObject(mapViewModel)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            SearchView()
                .environmentObject(dataStore)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search Notes")
                }
            SettingView()
                .environmentObject(dataStore)
                .environmentObject(mapViewModel)
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("App Info")
                }
        }
    }
}

#Preview {
    ContentView()
}
