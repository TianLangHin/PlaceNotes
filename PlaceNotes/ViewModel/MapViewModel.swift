//
//  MapViewModel.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import MapKit
import SwiftUI

/// This ViewModel governs the behaviour of the `Map` inside `MapExploreView`.
/// It keeps an updated record of the coordinate that the user is focused on as well as the zoom factor.
/// This is used so that it can directly apply the map position to query APIs for nearby locations
/// via internal structs, creating a seamless and intuitive map interaction for the user.
class MapViewModel: ObservableObject {
    /// The observable property that keeps track of the user's field of vision.
    /// The values here are used for querying the external API.
    @Published var position: MapCameraPosition = .camera(MapCamera(centerCoordinate: .sydney, distance: 30000))

    /// These three properties also keep track of the user's position and viewpoint within the map.
    /// These are necessary since the `MapCameraPosition` instance will often return a `nil`
    /// when attempting to retrieve these values after the map has moved,
    /// making it otherwise impossible to query the APIs with the current map location.
    @Published var latitude: Double = -33.8837
    @Published var longitude: Double = 151.2006
    @Published var height: Double = 30000

    /// Controls which kind of locations will be searched for.
    /// This is stored here and not as a `@State` inside `MapExploreView` so that annotations
    /// can remain persistent when switching between tab items.
    @Published var locationSelection: LocationCategory? = nil

    /// An array of all the locations to place a marker for on the map. It contains either
    /// a known place (a coordinate with some note attached) or a newly fetched location.
    @Published var annotations: [PlaceAnnotation] = []

    /// The two resources used for fetching externally from the API.
    let cityFetcher = CityFetcher()
    let locationFetcher = LocationFetcher()

    /// Adjustable properties that adjust the results of the API queries.
    @Published var cityQueryLimit: Double = 5
    @Published var locationQueryLimit: Double = 40

    /// Jumps the focus of the map to a new location, specified by latitude and longitude.
    func setLocationTo(latitude: Double, longitude: Double) {
        let coordinate: CLLocationCoordinate2D = .init(latitude: latitude, longitude: longitude)
        self.position = .camera(MapCamera(centerCoordinate: coordinate, distance: height))
    }

    /// Lowers the height of the map camera position, causing a "zoom in" effect without changing coordinate.
    func zoomIn(by factor: Double) {
        self.height /= factor
        let coordinate: CLLocationCoordinate2D = .init(latitude: latitude, longitude: longitude)
        self.position = .camera(MapCamera(centerCoordinate: coordinate, distance: height))
    }

    /// Increases the height of the map camera position, causing a "zoom out" effect without changing coordinate.
    func zoomOut(by factor: Double) {
        self.height *= factor
        let coordinate: CLLocationCoordinate2D = .init(latitude: latitude, longitude: longitude)
        self.position = .camera(MapCamera(centerCoordinate: coordinate, distance: height))
    }

    /// To be called on a regular basis. When the user drags and moves the map,
    /// update the properties other than `self.position` so that API calls will be updated with the new location.
    func refresh(context: MapCameraUpdateContext) {
        self.latitude = context.region.center.latitude
        self.longitude = context.region.center.longitude
        self.height = context.camera.distance
    }

    /// External API call to search for cities by a certain name. Returns the list of matching cities and their location data.
    func searchCity(_ queryString: String) async -> [CityData] {
        return await cityFetcher.fetch(CityParams(city: queryString, queryLimit: Int(self.cityQueryLimit))) ?? []
    }

    /// External API call to search for nearby locations of a certain category.
    /// Rather than returning the results, running this query places markers for every returned place on the map.
    /// It returns whether the query responded with an empty list, so that the UI knows whether to alert the user of this.
    func searchLocations(_ category: LocationCategory) async -> Bool {
        // The external API searches within a certain area (which could be a circle, rectangle or polygon).
        // For intuitiveness, just a circle query is used here.
        let field = CircleQuery(lon: self.longitude, lat: self.latitude, radiusMetres: 5000)
        let params = LocationParams(category: category, filter: .circle(field), queryLimit: Int(self.locationQueryLimit))
        // After building the parameters, the API is queried.
        let locations = await locationFetcher.fetch(params) ?? []
        await MainActor.run {
            // Then, for every location returned, a new annotation is placed on the map
            // by updating the `annotations` property which is observed by the `MapExploreView`.
            self.annotations = locations.map { location in
                PlaceAnnotation(mapPoint: .location(location))
            }
        }
        // If no results were found, then the UI should display an alert so the user does not think the app crashed.
        return locations.isEmpty
    }

    /// This returns the list of annotations that do not share a coordinate with the list of known `places`.
    /// Since the map will display both new locations and known places, duplicates need to be removed as such.
    func notSavedLocations(saved places: [Place]) -> [PlaceAnnotation] {
        return self.annotations.filter { location in
            switch location.mapPoint {
                case let .location(locationData):
                    return places.allSatisfy { place in
                        // Uses a custom logic implemented on the `LocationData` struct
                        // to see if it is identical to a known place.
                        !locationData.matchesWith(place: place)
                    }
                case .place:
                    // Naturally, if any annotation is a known place, this should be filtered away anyway.
                    return false
            }
        }
    }

    /// This returns the full list of newly-seen locations and saved places
    /// as a series of `PlaceAnnotation` instances, the result of which is to be displayed on the map.
    /// While the `annotations` property contains all the necessary information,
    /// this function streamlines it by removing all duplicates.
    func classifiedLocations(saved places: [Place]) -> [PlaceAnnotation] {
        let locations = self.notSavedLocations(saved: places)
        let places = places.map { place in
            PlaceAnnotation(mapPoint: .place(place))
        }
        return locations + places
    }
}

/// To make the default location Sydney, this convenience static member was made.
extension CLLocationCoordinate2D {
    static var sydney: CLLocationCoordinate2D {
        .init(latitude: -33.8837, longitude: 151.2006)
    }
}

/// The class that represents every marker that will be placed on the map.
/// It conforms to `MKAnnotation` so that it can be placed inside the body of a map
/// and conform to the `MapContentView` type.
class PlaceAnnotation: NSObject, MKAnnotation, Identifiable {
    let id = UUID()
    // The `coordinate` property is required to conform to `MKAnnotation`.
    var coordinate: CLLocationCoordinate2D
    let mapPoint: MapPoint

    init(mapPoint: MapPoint) {
        self.mapPoint = mapPoint
        // The coordinate can be derived directly from the `MapPoint` enum,
        // which functions as a union type of `Place` and `LocationData`.
        // Both possibilities have a latitude and longitude.
        switch mapPoint {
        case let .place(placeData):
            self.coordinate = .init(latitude: placeData.latitude, longitude: placeData.longitude)
        case let .location(locationData):
            self.coordinate = .init(latitude: locationData.latitude, longitude: locationData.longitude)
        }
    }
}

/// The type of data that is stored in a `PlaceAnnotation`.
/// Since an annotation on the map can either be a known place (`Place`) or an unseen location (`LocationData`),
/// `MapPoint` is implemented as an enum to function as a union type.
enum MapPoint {
    case place(Place)
    case location(LocationData)

    // Both the `Place` and `LocationData` type share many common properties.
    // In other parts of the codebase, such common properties need to be extracted
    // regardless of the enum variant. These computed properties are thus implemented below.

    var name: String {
        switch self {
        case let .place(placeData):
            return placeData.name
        case let .location(locationData):
            return locationData.name
        }
    }

    var categories: [String] {
        switch self {
        case let .place(placeData):
            return placeData.categories
        case let .location(locationData):
            return locationData.categories
        }
    }
}
