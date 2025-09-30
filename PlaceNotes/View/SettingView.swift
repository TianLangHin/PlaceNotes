//
//  SettingView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 26/9/2025.
//

import SwiftUI

/// The fourth View that the user of the app will see.
/// This View will provide both a brief explanation of the app
/// as well as the customisation of some settings.
struct SettingView: View {
    // This View will enable the user to clear all existing data,
    // hence access to the persistent storage is required through the `DataStoreViewModel`.
    @EnvironmentObject var dataStore: DataStoreViewModel

    // This View will also provide functionality to adjust how many results
    // to return during each of the queries in `MapExploreView`.
    // Hence, it needs access to the `MapViewModel` too.
    @EnvironmentObject var mapViewModel: MapViewModel

    // The data clearing button will show a confirmation dialog before deletion.
    // This state variable toggles the state of this appearance.
    @State var isShowingDialog = false

    var body: some View {
        VStack {
            // The title of this view is in a large font and bolded at the top.
            HStack {
                Spacer()
                Text("About the App")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            // Under this, a brief explanation of the main app functionalities is listed,
            // with associated icons on the left to indicate where this functionality
            // is most likely to be seen.
            ScrollView {
                VStack(alignment: .leading) {
                    // Starting paragraph of overall introduction.
                    Text("""
                    PlaceNotes records notes and sets reminders \
                    while attaching them to locations on a map for visualisation.
                    """)
                    // About the first page.
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("""
                    You can view and edit your PlaceNotes \
                    while keeping track of their urgency,
                    """)
                    }
                    .padding()
                    // About the second page.
                    HStack {
                        Image(systemName: "map.fill")
                        Text("""
                    See your favourite locations and visualise your notes on the map,
                    """)
                    }
                    .padding()
                    // About the third page.
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("""
                    And browse through your notes and favourite locations \
                    at your leisure.
                    """)
                    }
                    .padding()
                    // About the overall logic of preserving Places in the database.
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("""
                    Your favourite locations stay your map \
                    even if you don't have notes for them.
                    """)
                    }
                    .padding()
                }
            }
            .frame(height: 400)
            // The section at the bottom allows the customisation of settings.
            Divider()
            HStack {
                Spacer()
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
            }
            // A slider to customise how many city results to return.
            VStack(alignment: .center) {
                Text("Maximum results per city search: \(Int(mapViewModel.cityQueryLimit))")
                Slider(value: $mapViewModel.cityQueryLimit, in: 1...10, step: 1) {
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("10")
                }
            }
            // A slider to customise how many nearby locations to search for at once.
            VStack(alignment: .center) {
                Text("Maximum results per location search: \(Int(mapViewModel.locationQueryLimit))")
                Slider(value: $mapViewModel.locationQueryLimit, in: 10...50, step: 1) {
                } minimumValueLabel: {
                    Text("10")
                } maximumValueLabel: {
                    Text("50")
                }
            }
            Spacer()
            // Functionality to clear all the rows in the internal database.
            Button("Clear All Data") {
                isShowingDialog.toggle()
            }
            .confirmationDialog("Clear Data?", isPresented: $isShowingDialog) {
                // The confirmation dialogue prompts the user whether they
                // really do want to remove all the data.
                Button("OK", role: .destructive) {
                    // If the user selects OK, then the deletion goes ahead.
                    let _ = dataStore.completeReset()
                }
                Button("Cancel", role: .cancel) {
                    // Otherwise, do nothing here.
                }
            } message: {
                Text("Are you sure you want to clear all your notes and favourite places?")
            }
            .foregroundStyle(.red) // Red signifies a potentially dangerous operations.
            .padding()
        }
        .padding()
    }
}

#Preview {
    SettingView()
        .environmentObject(DataStoreViewModel())
        .environmentObject(MapViewModel())
}
