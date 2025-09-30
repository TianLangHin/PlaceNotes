//
//  MapExploreView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import MapKit
import SwiftUI

/// This View contains the main feature of this app.
/// It visualises all the notes that the user has made on a map,
/// and displays nearby locations that the user may be interested in as well.
struct MapExploreView: View {
    // This View will require access to all existing notes and known places
    // and the ability to edit the data contained in the persistent SQLite database.
    @EnvironmentObject var dataStore: DataStoreViewModel

    // Additional map settings are editable by other views,
    // hence the `MapViewModel` is passed as an environment object.
    @EnvironmentObject var mapViewModel: MapViewModel

    // Internal state to keep track of the map status and related queries.
    @State var citySearch = ""
    @State var resultsText = "Start searching to find cities!"
    @State var lastQuery: [CityData] = []

    // This controls the state of the `Map`, enabling the `Marker`s placed on the map
    // to be selectable by the user to open another sheet view for editing.
    @State var selectedPlace: PlaceAnnotation? = nil

    // Controller for whether an alert appears (needed for API calls returning empty).
    @State var isAlerting = false

    var body: some View {
        VStack {
            // Title of the View
            HStack {
                Spacer()
                Text("Notes Map")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            // The search bars which allow the user to query the APIs
            // are at the top of the view. Each are implemented as a sub-view.
            VStack(spacing: 0) {
                citySearchBar()
                placeSearchBar()
            }
            // Zoom buttons are overlaid on the map, hence the Map is in a ZStack.
            ZStack {
                // The map is the main feature of the UI.
                // The `MapViewModel` keeps track of and manages updates to the
                // Map's position, and the Map also keeps track of a selected Marker.
                Map(position: $mapViewModel.position, selection: $selectedPlace) {
                    // The annotations to be displayed are governed by the `mapViewModel`.
                    // Each annotation is either a known place or a newly-fetched one.
                    let locations = mapViewModel.classifiedLocations(saved: dataStore.places)
                    // This initialiser body conforms to the `MapContentView` protocol,
                    // as it is made solely out of `Group` and `Marker` elements.
                    ForEach(locations) { annotation in
                        // Enclosing the `Marker`s in a `Group` allows the Map
                        // to keep track of when a `Marker` is selected.
                        Group {
                            switch annotation.mapPoint {
                            case let .place(place):
                                // An annotation indicating a known place will be indicated
                                // with a red marker, containing a heart icon if it is
                                // a favourite or a bookmark if it is not.
                                Marker(coordinate: annotation.coordinate) {
                                    VStack {
                                        let img = place.isFavourite ? "heart" : "bookmark"
                                        Image(systemName: "\(img).fill")
                                        Text(annotation.mapPoint.name)
                                    }
                                }
                                .tint(.red)
                            case .location:
                                // An annotation indicating a newly fetched location
                                // is an orange marker with a circle contained in it.
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
                    // When a marker is selected, a sheet view will be popped up.
                    switch selectedPlace.mapPoint {
                    case let .place(knownPlace):
                        // If the place is already known,
                        // then the user may toggle its details and add/delete notes from it.
                        KnownPlaceView(place: knownPlace)
                            .environmentObject(dataStore)
                    case let .location(newLocation):
                        // If the place is newly fetched, then the user must make a new note
                        // attached to it first before it is stored in the database.
                        NewNoteView(attachedLocation: .location(newLocation))
                            .environmentObject(dataStore)
                    }
                }
                .onMapCameraChange(frequency: .onEnd) { mapUpdateCtx in
                    // This ensures that the `mapViewModel` will use updated coordinates
                    // to query for nearby locations.
                    mapViewModel.refresh(context: mapUpdateCtx)
                }
                // This layer sits on top of the map, providing zoom in and zoom out
                // buttons near the bottom of the screen where it is convenient for users.
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            // A smooth animation is used when lowering the camera height
                            // to zoom in on the map.
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
                            // A smooth animation is used when increasing the camera height
                            // to zoom out on the map.
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
            // This alert is used for the situation where an API query
            // returns a blank list. The user may think the app has frozen
            // or crashed in such situations unless otherwise indicated,
            // hence this alert pops up when an empty response is given.
            Button("OK", role: .cancel) {}
        }
    }

    // A sub-view that allows the user to search for a city
    // and jump the map to the coordinates of that city.
    func citySearchBar() -> some View {
        VStack {
            HStack {
                // The user can enter a city name to search for on the left.
                TextField("City name", text: $citySearch)
                Spacer()
                // The user can then trigger the search with the button the right.
                Button {
                    Task {
                        // The MapViewModel contains the city searching functionality,
                        // returning the list of cities in an async function.
                        // When the search is completed, the searching text field is cleared,
                        // and the number of found cities is shown on the menu dropdown.
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
                // Every item in the dropdown list is clickable to jump to the
                // corresponding city.
                ForEach(lastQuery, id: \.self) { city in
                    Button {
                        // This makes the item tappable such that it will
                        // jump to map to the correct coordinate.
                        mapViewModel.setLocationTo(latitude: city.latitude, longitude: city.longitude)
                    } label: {
                        // The label of each button is brief,
                        // showing the city name, country (for intuitive disambiguation)
                        // and the coordinates (for rigorous disambiguation).
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
                    // The title of the menu indicates how many cities were returned
                    // so the user can see its change and know that the search has completed,
                    // and click on the dropdown to select the city to jump to.
                    Text(resultsText)
                    Image(systemName: "chevron.up")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .border(.black, width: 2)
        // The strong surrounding border indicates an individual functionality to the user.
    }

    // A sub-view that allows the user to search for nearby places of a particular category
    // and display all these places as markers on the map.
    func placeSearchBar() -> some View {
        VStack {
            HStack {
                // The dropdown menu allows the user to select a category,
                // the possible values of which are defined by the `LocationCategory` enum.
                Menu("Places") {
                    // Each item in the dropdown menu will set the selected location
                    // (`mapViewModel.locationSelection`) through a button execution.
                    ForEach(LocationCategory.allCases, id: \.self) { category in
                        Button {
                            mapViewModel.locationSelection = category
                        } label: {
                            Text("\(category.displayName())")
                        }
                    }
                }
                Spacer()
                // The view starts off with a `nil` selection (no category selected),
                // but is modified when the user selects a category.
                if let category = mapViewModel.locationSelection {
                    // If there is a selection, the user is prompt to conduct the search.
                    // This is done through the right chevron icon pointing at
                    // the display button.
                    HStack {
                        Spacer()
                        Text(category.displayName())
                        Image(systemName: "chevron.right")
                        Spacer()
                    }
                } else {
                    // If the selection is nil, the user is prompted to select one
                    // through the text and the left chevron icon to point to the menu.
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Select a search category!")
                            .multilineTextAlignment(.center)
                    }
                }
                Spacer()
                // The display button conducts the nearby place search via the MapViewModel.
                // If the returned list is empty, `isAlerting` is set to true
                // to pop up the notification to the user.
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
            // If the user no longer wants to look at surrounding places but just their
            // own notes, this button provides the functionality to clear other results.
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
        // The strong surrounding border indicates an individual functionality to the user.
    }
}

#Preview {
    MapExploreView()
        .environmentObject(DataStoreViewModel())
        .environmentObject(MapViewModel())
}
