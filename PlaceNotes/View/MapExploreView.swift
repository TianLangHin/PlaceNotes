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
    @State var lastQuery: [CityData] = []

    @State var selectedPlace: PlaceAnnotation? = nil

    @EnvironmentObject var dataStore: DataStoreViewModel
    @EnvironmentObject var mapViewModel: MapViewModel

    @State var isAlerting = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Notes Map")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            VStack(spacing: 0) {
                citySearchBar()
                placeSearchBar()
            }
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
                .sheet(item: $selectedPlace) { selectedPlace in
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
            }
        }
        .alert("No results nearby for this category!", isPresented: $isAlerting) {
            Button("OK", role: .cancel) {}
        }
    }

    func citySearchBar() -> some View {
        VStack {
            HStack {
                TextField("City name", text: $citySearch)
                Spacer()
                Button {
                    Task {
                        lastQuery = await mapViewModel.searchCity(citySearch)
                        citySearch = ""
                        resultsText = "Found cities: \(lastQuery.count)"
                    }
                } label: {
                    Text("Search")
                }
                .buttonStyle(.borderedProminent)
            }
            Menu {
                ForEach(lastQuery, id: \.self) { city in
                    Button {
                        mapViewModel.setLocationTo(latitude: city.latitude, longitude: city.longitude)
                    } label: {
                        let cityCountryName = "\(city.city), \(city.country)"
                        let latValue = city.latitude.formatted(.number.precision(.fractionLength(4)))
                        let lonValue = city.longitude.formatted(.number.precision(.fractionLength(4)))
                        let latitude = "\(latValue)\(city.latitude >= 0 ? "°N" : "°S")"
                        let longitude = "\(lonValue)\(city.longitude >= 0 ? "°E" : "°W")"
                        Text("\(cityCountryName)\n(\(latitude), \(longitude))")
                    }
                }
            } label: {
                HStack {
                    Text(resultsText)
                    Image(systemName: "chevron.up")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .border(.black, width: 2)
    }

    func placeSearchBar() -> some View {
        VStack {
            HStack {
                Menu("Places") {
                    ForEach(LocationCategory.allCases, id: \.self) { category in
                        Button {
                            mapViewModel.locationSelection = category
                        } label: {
                            Text("\(category.displayName())")
                        }
                    }
                }
                Spacer()
                if let category = mapViewModel.locationSelection {
                    HStack {
                        Spacer()
                        Text(category.displayName())
                        Image(systemName: "chevron.right")
                        Spacer()
                    }
                } else {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Select a search category!")
                            .multilineTextAlignment(.center)
                    }
                }
                Spacer()
                Button {
                    Task {
                        if let category = mapViewModel.locationSelection {
                            let noResults = await mapViewModel.searchLocations(category)
                            if noResults {
                                isAlerting = true
                            }
                        }
                    }
                } label: {
                    Text("Display")
                }
                .buttonStyle(.borderedProminent)
            }
            HStack {
                Spacer()
                Button {
                    mapViewModel.annotations = []
                } label: {
                    Text("Clear Location Markers")
                }
                Spacer()
            }
        }
        .padding()
        .border(.black, width: 2)
    }
}

#Preview {
    MapExploreView()
        .environmentObject(DataStoreViewModel())
        .environmentObject(MapViewModel())
}
