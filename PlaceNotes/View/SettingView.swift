//
//  SettingView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 26/9/2025.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var dataStore: DataStoreViewModel
    @EnvironmentObject var mapViewModel: MapViewModel

    @State var isShowingDialog = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("About the App")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            ScrollView {
                VStack(alignment: .leading) {
                    Text("""
                    PlaceNotes records notes and sets reminders \
                    while attaching them to locations on a map for visualisation.
                    """)
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("""
                    You can view and edit your PlaceNotes \
                    while keeping track of their urgency,
                    """)
                    }
                    .padding()
                    HStack {
                        Image(systemName: "map.fill")
                        Text("""
                    See your favourite locations and visualise your notes on the map,
                    """)
                    }
                    .padding()
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("""
                    And browse through your notes and favourite locations \
                    at your leisure.
                    """)
                    }
                    .padding()
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
            Divider()
            HStack {
                Spacer()
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
            }
            VStack(alignment: .center) {
                Text("Maximum results per city search: \(Int(mapViewModel.cityQueryLimit))")
                Slider(value: $mapViewModel.cityQueryLimit, in: 1...10, step: 1) {
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("10")
                }
            }
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
            Button("Clear All Data") {
                isShowingDialog.toggle()
            }
            .confirmationDialog("Clear Data?", isPresented: $isShowingDialog) {
                Button("OK", role: .destructive) {
                    let _ = dataStore.completeReset()
                }
                Button("Cancel", role: .cancel) {
                    // Do nothing here.
                }
            } message: {
                Text("Are you sure you want to clear all your notes and favourite places?")
            }
            .foregroundStyle(.red)
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
