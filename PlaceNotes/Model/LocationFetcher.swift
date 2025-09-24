//
//  LocationFetcher.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

struct LocationFetcher: APIFetchable {
    typealias Parameters = LocationParams
    typealias FetchedData = [LocationData]

    func fetch(_ parameters: Parameters) async -> FetchedData? {
        let endpoint = "https://api.geoapify.com/v2/places"
        guard var requestUrl = URLComponents(string: endpoint) else {
            return nil
        }
        let paramList = [
            URLQueryItem(name: "categories", value: parameters.category.rawValue),
            URLQueryItem(name: "filter", value: parameters.filter.toString()),
            URLQueryItem(name: "limit", value: String(parameters.queryLimit)),
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "apiKey", value: API_KEY)
        ]
        requestUrl.queryItems = paramList
        let jsonDecoder = JSONDecoder()
        guard let url = requestUrl.url else {
            return nil
        }
        guard let (response, _) = try? await URLSession.shared.data(from: url) else {
            return nil
        }
        guard let data = try? jsonDecoder.decode(RawLocationData.self, from: response) else {
            return nil
        }
        return data.features.map { $0.properties }
    }
}

struct LocationParams {
    let category: LocationCategory
    let filter: LocationFilter
    let queryLimit: Int
}

struct LocationData: Codable {
    let name: String
    let categories: [String]
    let latitude: Double
    let longitude: Double
    let country: String

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case categories = "categories"
        case latitude = "lat"
        case longitude = "lon"
        case country = "country"
    }
}

enum LocationCategory: String, Hashable, CaseIterable {
    case accommodation = "accommodation"
    case childcare = "childcare"
    case commercial = "commercial"
    case clothing = "commercial.clothing"
    case foodAndDrink = "commercial.food_and_drink"
    case emergency = "emergency"
    case education = "education"
    case entertainment = "entertainment"
    case healthcare = "healthcare"
    case leisure = "leisure"
    case office = "office"
    case government = "office.government"
    case lawyer = "office.lawyer"
    case telecommunication = "office.telecommunication"
    case publicTransport = "public_transport"
    case service = "service"
    case sport = "sport"
    case tourism = "tourism"
    case religion = "religion"

    func displayName() -> String {
        switch self {
        case .accommodation:
            "Accommodation"
        case .childcare:
            "Childcare"
        case .commercial:
            "Commercial Buildings"
        case .clothing:
            "Clothing"
        case .foodAndDrink:
            "Food and Drink"
        case .emergency:
            "Emergency"
        case .education:
            "Education"
        case .entertainment:
            "Entertainment"
        case .healthcare:
            "Healthcare"
        case .leisure:
            "Leisure"
        case .office:
            "Offices"
        case .government:
            "Government Buildings"
        case .lawyer:
            "Lawyer Offices"
        case .telecommunication:
            "Telecommunications"
        case .publicTransport:
            "Public Transport"
        case .service:
            "Public Services"
        case .sport:
            "Sports Facilities"
        case .tourism:
            "Tourism"
        case .religion:
            "Religious"
        }
    }
}

enum LocationFilter {
    case circle(CircleQuery)
    case rectangle(RectangleQuery)

    func toString() -> String {
        switch self {
        case let .circle(circle):
            return circle.toString()
        case let .rectangle(rectangle):
            return rectangle.toString()
        }
    }
}

struct CircleQuery {
    let lon: Double
    let lat: Double
    let radiusMetres: Int

    func toString() -> String {
        return "circle:\(lon),\(lat),\(radiusMetres)"
    }
}

struct RectangleQuery {
    let lon1: Double
    let lat1: Double
    let lon2: Double
    let lat2: Double

    func toString() -> String {
        return "rect:\(lon1),\(lat1),\(lon2),\(lat2)"
    }
}

struct RawLocationData: Codable {
    let features: [RawLocationFeature]
}

struct RawLocationFeature: Codable {
    let properties: LocationData
}
