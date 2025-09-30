//
//  LocationFetcher.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

/// This struct uses the Places API from Geoapify to fetch a list
/// of nearby locations that fall under a certain category.
struct LocationFetcher: APIFetchable {
    // A custom struct denoting each of the parameters needed to customise the API call is used
    // as the generic `Parameters` associated type.
    typealias Parameters = LocationParams
    // The returned data should be a list of locations.
    typealias FetchedData = [LocationData]

    func fetch(_ parameters: Parameters) async -> FetchedData? {
        // The API endpoint for the Places API in Geoapify.
        let endpoint = "https://api.geoapify.com/v2/places"
        // If the URL is malformed at this stage already, then ths API call fails.
        guard var requestUrl = URLComponents(string: endpoint) else {
            return nil
        }
        // Each key-value pair within the API call is listed as follows,
        // and combined into a set of URL parameters passed to the API call.
        // These follow the specification as required by the Geoapify API docs.
        requestUrl.queryItems = [
            // The `LocationCategory` enum is written such that the raw string value corresponds
            // to the API's expected value.
            URLQueryItem(name: "categories", value: parameters.category.rawValue),
            // The `toString()` method of the `LocationFilter` struct is also designed to
            // interact directly with the API requirements.
            URLQueryItem(name: "filter", value: parameters.filter.toString()),
            URLQueryItem(name: "limit", value: String(parameters.queryLimit)),
            URLQueryItem(name: "lang", value: "en"),
            // The API key is defined in ApiKey.swift, and is needed to authenticate every APi call.
            URLQueryItem(name: "apiKey", value: API_KEY)
        ]

        // The returned data will be a JSON format.
        let jsonDecoder = JSONDecoder()
        guard let url = requestUrl.url else {
            // The API call will not work if the URL is malformed.
            return nil
        }
        guard let (response, _) = try? await URLSession.shared.data(from: url) else {
            // The API call is made here, and the response is stored.
            // If the call fails, an error is thrown and a `nil` is returned.
            return nil
        }
        guard let data = try? jsonDecoder.decode(RawLocationData.self, from: response) else {
            // If the data is not of the right form, then the result cannot be returned.
            return nil
        }
        // The `LocationData` instances are extracted from the returned `RawLocationData` object.
        return data.features.map { $0.properties }
    }
}

/// From the usage within the app, there are only three values that need to be customised
/// for each Geoapify Places API call: the `category` of place to look for,
/// the region within which to look for places (i.e., `filter`),
/// and the maximum number of places to look for within the region (`queryLimit`).
struct LocationParams {
    let category: LocationCategory
    let filter: LocationFilter
    let queryLimit: Int
}

/// The API is expected to return a list of `LocationData` objects which are represented via JSON,
/// each representing a city that potentially matches the query.
struct LocationData: Codable {
    let name: String
    let categories: [String]
    let latitude: Double
    let longitude: Double
    let country: String

    // The returned data will return a JSON with keys that have a naming convention slightly different
    // from our internal representation, hence CodingKeys is used to translate between these.
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case categories = "categories"
        case latitude = "lat"
        case longitude = "lon"
        case country = "country"
    }

    /// This is a function that halps with the logic of `MapViewModel`,
    /// identifying whether a location returned from an API call is identical with a known `Place`.
    func matchesWith(place: Place) -> Bool {
        // We only match based on name, latitude and longitude, since categories may change over time.
        return self.name == place.name && self.latitude == place.latitude && self.longitude == place.longitude
    }
}

/// This is a subset of all possible filter categories accepted by the Places API.
enum LocationCategory: String, Hashable, CaseIterable {
    // Each of the raw string values correspond to what the Places API expects,
    // while the enum variant name is for intuitive usage and reference within the API.
    case accommodation = "accommodation"
    case childcare = "childcare"
    case clothing = "commercial.clothing"
    case commercial = "commercial"
    case education = "education"
    case emergency = "emergency"
    case entertainment = "entertainment"
    case foodAndDrink = "commercial.food_and_drink"
    case government = "office.government"
    case healthcare = "healthcare"
    case lawyer = "office.lawyer"
    case leisure = "leisure"
    case office = "office"
    case publicTransport = "public_transport"
    case religion = "religion"
    case service = "service"
    case sport = "sport"
    case telecommunication = "office.telecommunication"
    case tourism = "tourism"

    /// Additionally, the user will need to select from these enum variants to choose
    /// which kind of place to look for. Neither the raw string value (for the API)
    /// nor the in-code enum name is made for human readability, hence `displayName()`
    /// returns a human readable string describing the enum variant.
    func displayName() -> String {
        switch self {
        case .accommodation:
            "Accommodation"
        case .childcare:
            "Childcare"
        case .clothing:
            "Clothing"
        case .commercial:
            "Commercial Buildings"
        case .education:
            "Education"
        case .emergency:
            "Emergency"
        case .entertainment:
            "Entertainment"
        case .foodAndDrink:
            "Food and Drink"
        case .government:
            "Government Buildings"
        case .healthcare:
            "Healthcare"
        case .lawyer:
            "Lawyer Offices"
        case .leisure:
            "Leisure"
        case .office:
            "Offices"
        case .service:
            "Public Services"
        case .publicTransport:
            "Public Transport"
        case .religion:
            "Religious"
        case .sport:
            "Sports Facilities"
        case .telecommunication:
            "Telecommunications"
        case .tourism:
            "Tourism"
        }
    }
}

/// This serves as a union type of either a circle search area or a rectangular search area
/// when looking for nearby locations through the Places API in Geoapify.
enum LocationFilter {
    // The circle and rectangle search settings are represented as variants of the enum.
    case circle(CircleQuery)
    case rectangle(RectangleQuery)

    /// This function is required to turn the in-code representation of the search area
    /// into the representation required by the Places API.
    /// Both `CircleQuery` and `RectangleQuery` have their own string representations,
    /// but in either case this is the required representation.
    func toString() -> String {
        switch self {
        case let .circle(circle):
            return circle.toString()
        case let .rectangle(rectangle):
            return rectangle.toString()
        }
    }
}

/// This indicates a search for nearby locations within a set radius out
/// from the centre of the map's field of vision.
struct CircleQuery {
    // To define the circle, you need the coordinates
    // (longitude being `lon` and latitude being `lan`)
    // and the radius of the circle in metres (`radiusMetres`).
    let lon: Double
    let lat: Double
    let radiusMetres: Int

    // The required representation in the API has the prefix "circle:"
    // followed by the comma delimited list of longitude, latitude, and radius.
    func toString() -> String {
        return "circle:\(lon),\(lat),\(radiusMetres)"
    }
}

/// This indicates a search for nearby locations within a rectangular area
/// specified by opposing corners of the rectangle.
struct RectangleQuery {
    // `lon1` and `lat1` are the coordinates of one corner of the rectangle.
    // `lon2` and `lat2` are the coordinates of the opposing corner of the rectangle.
    let lon1: Double
    let lat1: Double
    let lon2: Double
    let lat2: Double

    // The required representation in the API has the prefix "rect:"
    // followed by the comma delimited list of the the two opposing points.
    func toString() -> String {
        return "rect:\(lon1),\(lat1),\(lon2),\(lat2)"
    }
}

/// Since the API returns a JSON of a structure `{ features: [{ properties: <actual location data> }] }`,
/// the next two structs are used as a way to conform to its structure while still
/// enabling the extraction of the necessary information in our desired format.

struct RawLocationData: Codable {
    let features: [RawLocationFeature]
}

struct RawLocationFeature: Codable {
    let properties: LocationData
}
