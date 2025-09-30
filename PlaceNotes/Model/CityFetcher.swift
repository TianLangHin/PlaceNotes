//
//  CityFetcher.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

/// This struct uses the Geocoding API from Geoapify to fetch a list
/// of cities that match a certain string query from the user.
struct CityFetcher: APIFetchable {
    // For this purpose, custom representations for the API call parameters
    // and the returned data are specified.
    typealias Parameters = CityParams
    typealias FetchedData = [CityData]

    func fetch(_ parameters: Parameters) async -> FetchedData? {
        // The API endpoint is as indicated by the Geoapify docs.
        let endpoint = "https://api.geoapify.com/v1/geocode/search"
        // If the URL is no longer valid, then this API fetch cannot work.
        guard var requestUrl = URLComponents(string: endpoint) else {
            return nil
        }
        // The parameters to the Geoapify API call are provided as follows.
        // From the app's internal perspective, only `text` and `limit` may be changed.
        // The other parameters are set values here to ensure expected behaviour,
        // and one of these is the private API key defined in `ApiKey.swift`.
        requestUrl.queryItems = [
            URLQueryItem(name: "text", value: parameters.city),
            URLQueryItem(name: "type", value: "city"),
            URLQueryItem(name: "limit", value: String(parameters.queryLimit)),
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "apiKey", value: API_KEY)
        ]

        // The returned data is expected to be a JSON object.
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
        guard let data = try? jsonDecoder.decode(RawCityData.self, from: response) else {
            // If the data is not of the right form, then the result cannot be returned.
            return nil
        }
        // The `CityData` instances are extracted from the returned `RawCityData` object.
        return data.features.map { $0.properties }
    }
}

/// For this app's purpose, the parameters to the Geocoding API call are just
/// the city name and the number of possible cities at maximum to search for.
struct CityParams {
    let city: String
    let queryLimit: Int
}

/// The API is expected to return a list of JSON objects
/// each representing a city that potentially matches the query.
struct CityData: Codable {
    // All that is required for this app's purpose is the name, coordinates, and country it belongs to.
    let city: String
    let latitude: Double
    let longitude: Double
    let country: String
}

/// Since the API returns a JSON of a structure `{ features: [{ properties: <actual city data> }] }`,
/// the next two structs are used as a way to conform to its structure while still
/// enabling the extraction of the necessary information in our desired format.

struct RawCityData: Codable {
    let features: [RawCityFeature]
}

struct RawCityFeature: Codable {
    let properties: CityData
}
