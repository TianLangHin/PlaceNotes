//
//  MapExploreView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import MapKit
import SwiftUI

struct MapExploreView: View {
    @State var citySearch = ""
    @State var resultsText = "Start searching to find cities!"
    @State var locationSelection: LocationCategory? = nil
    @State var lastQuery: [IdWrapper<CityData>] = []

    @State var selectedPlace: PlaceAnnotation? = nil

    @EnvironmentObject var dataStore: DataStoreViewModel
    @ObservedObject var mapViewModel = MapViewModel()

    var body: some View {
        VStack {
            citySearchBar()
            placeSearchBar()
            ZStack {
                Map(position: $mapViewModel.position, selection: $selectedPlace) {
                    ForEach(mapViewModel.classifiedLocations(saved: dataStore.places)) { annotation in
                        Group {
                            switch annotation.mapPoint {
                            case let .place(place):
                                Marker(coordinate: annotation.coordinate) {
                                    VStack {
                                        let img = place.isFavourite ? "heart" : "bookmark"
                                        Image(systemName: "\(img).fill")
                                        Text(annotation.mapPoint.name)
                                    }
                                }
                                .tint(.red)
                            case .location:
                                Marker(coordinate: annotation.coordinate) {
                                    VStack {
                                        Image(systemName: "circle")
                                        Text(annotation.mapPoint.name)
                                    }
                                }
                                .tint(.orange)
                            }
                        }
                        .tag(annotation)
                    }
                }
                .sheet(item: $selectedPlace, onDismiss: {
                    locationSelection = nil
                }) { selectedPlace in
                    switch selectedPlace.mapPoint {
                    case let .place(knownPlace):
                        KnownPlaceView(place: knownPlace)
                            .environmentObject(dataStore)
                    case let .location(newLocation):
                        NewNoteView(attachedLocation: .location(newLocation))
                            .environmentObject(dataStore)
                    }
                }
                .onMapCameraChange(frequency: .onEnd) { mapUpdateCtx in
                    mapViewModel.refresh(context: mapUpdateCtx)
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Button {
                                withAnimation {
                                    mapViewModel.zoomIn(by: 2)
                                }
                            } label: {
                                Image(systemName: "plus.magnifyingglass")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            .clipShape(.circle)
                            .buttonStyle(.borderedProminent)
                            Button {
                                withAnimation {
                                    mapViewModel.zoomOut(by: 2)
                                }
                            } label: {
                                Image(systemName: "minus.magnifyingglass")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            .clipShape(.circle)
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
                .padding()
            }
        }
    }

    func citySearchBar() -> some View {
        VStack {
            HStack {
                TextField("City name", text: $citySearch)
                Spacer()
                Button {
                    Task {
                        let cities = await mapViewModel.searchCity(citySearch)
                        lastQuery = cities.map { IdWrapper(data: $0) }
                        citySearch = ""
                        resultsText = "Found cities: \(lastQuery.count)"
                    }
                } label: {
                    Text("Search")
                }
                .buttonStyle(.borderedProminent)
            }
            Menu(resultsText) {
                ForEach(lastQuery) { cityData in
                    let city = cityData.data
                    Button {
                        mapViewModel.setLocationTo(latitude: city.latitude, longitude: city.longitude)
                    } label: {
                        Text("\(city.city), \(city.country)\n (\(city.latitude), \(city.longitude))")
                    }
                }
            }
        }
        .padding()
        .border(.black)
    }

    func placeSearchBar() -> some View {
        HStack {
            // Toggle here
            Button {
                Task {
                    if let category = locationSelection {
                        await mapViewModel.searchLocations(category)
                    }
                }
            } label: {
                Text("Display")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
            if let category = locationSelection {
                Text("\(category.displayName())")
            }
            Spacer()
            Menu("Places") {
                ForEach(LocationCategory.allCases, id: \.self) { category in
                    Button {
                        locationSelection = category
                    } label: {
                        Text("\(category.displayName())")
                    }
                }
            }
        }
        .padding()
        .border(.black)
    }
}

#Preview {
    MapExploreView()
        .environmentObject(DataStoreViewModel())
}
