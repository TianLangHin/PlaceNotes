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
}

extension CLLocationCoordinate2D {
    static var sydney: CLLocationCoordinate2D {
        .init(latitude: -33.8837, longitude: 151.2006)
    }
}

class PlaceAnnotation: NSObject, MKAnnotation, Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    let place: Place

    init(place: Place) {
        self.place = place
        self.coordinate = .init(latitude: place.latitude, longitude: place.longitude)
    }
}
