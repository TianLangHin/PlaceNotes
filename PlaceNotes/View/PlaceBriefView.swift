//
//  PlaceBriefView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

/// This View is not intended to be displayed on its own as a page,
/// but rather as an element in a List that will pop up a sheet
/// to a view that allows editing of the `Place`.
struct PlaceBriefView: View {
    // Since this View will need to provide database manipulation operations
    // to the child Views that pop up via a sheet, it needs access to
    // the `DataStoreViewModel` as an EnvironmentObject as well.
    @EnvironmentObject var dataStore: DataStoreViewModel
    // The `CategoriesViewModel` instance provides a way to show the associated categories
    // in a user friendly manner.
    @State var converter = CategoriesViewModel()

    // The only argument required is the `Place` to be displayed.
    @State var place: Place

    // Since this View will provide pop ups as a sheet, this variable controls it.
    @State var isShowingSheet = false

    var body: some View {
        VStack {
            // The top of the brief place view shows the View's name
            // and its favourited status.
            HStack {
                Spacer()
                Text(place.name)
                    .font(.title3)
                    .fontWeight(.bold)
                // If it is favourited, it will appear on the right
                // as a filled red heart.
                if place.isFavourite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
                Spacer()
            }
            // Below the name of the place is a horizontal scrollable list
            // of all its associated categories.
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    let categories = converter.categoryNames(place.categories)
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .font(.system(size: 14))
                            .padding()
                            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding()
            }
        }
        .padding()
        .onTapGesture {
            // When this view is tapped, the `KnownPlaceView` will pop up as a sheet,
            // allowing the user to edit associated data of the place.
            isShowingSheet.toggle()
        }
        .sheet(isPresented: $isShowingSheet) {
            KnownPlaceView(place: place)
                .environmentObject(dataStore)
        }
    }
}

#Preview {
    PlaceBriefView(place: Place(
        id: 1,
        name: "Place Name",
        latitude: -1, longitude: 1, categories: ["entertainment.activity_park", "airport.international", "commercial.outdoor_and_sport"], isFavourite: true))
        .environmentObject(DataStoreViewModel())
}
