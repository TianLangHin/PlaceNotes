//
//  ContentView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 20/9/2025.
//

import SwiftUI

/// This view serves as the main page of the app,
/// with each of the core functionalities being intuitively
/// presented as tabs at the bottom of the screen.
/// This enables easy navigation through the app assisted by intuitive signifiers.
struct ContentView: View {
    /// The `dataStore` serves as a single source of truth in the app,
    /// being the only object directly usable by the app's views
    /// that accesses or manipulates the persistent SQLite database.
    @ObservedObject var dataStore = DataStoreViewModel()
    /// The `mapViewModel` enables tab items outside the `MapExploreView`
    /// to adjust the settings of the queries made while navigating the map.
    @ObservedObject var mapViewModel = MapViewModel()

    // By default, make the first page of the app the map that visualises notes.
    @State var selection = 2

    var body: some View {
        /// The main four pages of the app are presented with matching icons.
        /// All four of the pages will be provided `dataStore` as an
        /// EnvironmentObject, so that they can have access to the global
        /// single source of truth.
        TabView(selection: $selection) {
            /// The first page of the app is a summary of all the notes recorded,
            /// ordering on their dates so that the user can see which notes
            /// or reminders are most urgent.
            RankedNotesView()
                .environmentObject(dataStore)
                .tabItem {
                    /// A bell icon is used to signify its purpose of listing
                    /// notes in a time-based reminder format.
                    Image(systemName: "bell.fill")
                    Text("Notes")
                }
                .tag(1)
            /// The second page is the most interactive page where the user
            /// interacts with a map, visualising the distribution of their notes.
            MapExploreView()
                .environmentObject(dataStore)
                .environmentObject(mapViewModel)
                .tabItem {
                    /// Since the main navigation tool within this page is a map,
                    /// a map icon is used as the signifier.
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(2)
            /// The third page allows a more conventional searching within the user's
            /// notes, in case the user has many notes that cannot be easily
            /// visualised in full completion within the map.
            SearchView()
                .environmentObject(dataStore)
                .tabItem {
                    /// A magnifying glass icon is used to signify the functionality
                    /// of searching through the list of notes and places recorded.
                    Image(systemName: "magnifyingglass")
                    Text("Search Notes")
                }
                .tag(3)
            /// The final page provides setting customisations as well as
            /// basic information about the app. These customisations
            /// will affect the functionality of `MapExploreView`,
            /// hence it also has access to `mapViewModel`.
            SettingView()
                .environmentObject(dataStore)
                .environmentObject(mapViewModel)
                .tabItem {
                    /// To show that this app provides basic information
                    /// and potentially other utilities,
                    /// the information circle icon is used as the signifier.
                    Image(systemName: "info.circle")
                    Text("App Info")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
}
