//
//  MapViewModel.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import MapKit
import SwiftUI

class MapViewModel: ObservableObject {
    @Published var position: MapCameraPosition = .camera(MapCamera(centerCoordinate: .sydney, distance: 30000))
    @Published var latitude: Double = -33.8837
    @Published var longitude: Double = 151.2006
    @Published var height: Double = 30000

    @Published var annotations: [PlaceAnnotation] = []

    let cityFetcher = CityFetcher()
    let locationFetcher = LocationFetcher()

    let cityQueryLimit = 5
    let locationQueryLimit = 20

    func setLocationTo(latitude: Double, longitude: Double) {
        let coordinate: CLLocationCoordinate2D = .init(latitude: latitude, longitude: longitude)
        self.position = .camera(MapCamera(centerCoordinate: coordinate, distance: height))
    }

    func zoomIn(by factor: Double) {
        self.height /= factor
        let coordinate: CLLocationCoordinate2D = .init(latitude: latitude, longitude: longitude)
        self.position = .camera(MapCamera(centerCoordinate: coordinate, distance: height))
    }

    func zoomOut(by factor: Double) {
        self.height *= factor
        let coordinate: CLLocationCoordinate2D = .init(latitude: latitude, longitude: longitude)
        self.position = .camera(MapCamera(centerCoordinate: coordinate, distance: height))
    }

    func refresh(context: MapCameraUpdateContext) {
        self.latitude = context.region.center.latitude
        self.longitude = context.region.center.longitude
        self.height = context.camera.distance
    }

    func searchCity(_ queryString: String) async -> [CityData] {
        return await cityFetcher.fetch(CityParams(city: queryString, queryLimit: self.cityQueryLimit)) ?? []
    }

    func searchLocations(_ category: LocationCategory) async {
        let field = CircleQuery(lon: longitude, lat: latitude, radiusMetres: 5000)
        let params = LocationParams(category: category, filter: .circle(field), queryLimit: self.locationQueryLimit)
        let locations = await locationFetcher.fetch(params) ?? []
        self.annotations = locations.map { location in
            PlaceAnnotation(mapPoint: .location(location))
        }
    }
}

extension CLLocationCoordinate2D {
    static var sydney: CLLocationCoordinate2D {
        .init(latitude: -33.8837, longitude: 151.2006)
    }
}

class PlaceAnnotation: NSObject, MKAnnotation, Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    let mapPoint: MapPoint

    init(mapPoint: MapPoint) {
        self.mapPoint = mapPoint
        switch mapPoint {
        case let .place(placeData):
            self.coordinate = .init(latitude: placeData.latitude, longitude: placeData.longitude)
        case let .location(locationData):
            self.coordinate = .init(latitude: locationData.latitude, longitude: locationData.longitude)
        }
    }
}

enum MapPoint {
    case place(Place)
    case location(LocationData)

    var name: String {
        switch self {
        case let .place(placeData):
            return placeData.name
        case let .location(locationData):
            return locationData.name
        }
    }
}
