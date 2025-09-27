//
//  PlaceBriefView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

struct PlaceBriefView: View {
    @EnvironmentObject var dataStore: DataStoreViewModel
    @State var converter = CategoriesViewModel()
    @State var place: Place

    @State var isShowingSheet = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(place.name)
                    .font(.title3)
                    .fontWeight(.bold)
                if place.isFavourite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
                Spacer()
            }
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
