//
//  CityFetcher.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

struct CityFetcher: APIFetchable {
    typealias Parameters = CityParams
    typealias FetchedData = [CityData]

    func fetch(_ parameters: Parameters) async -> FetchedData? {
        let endpoint = "https://api.geoapify.com/v1/geocode/search"
        guard var requestUrl = URLComponents(string: endpoint) else {
            return nil
        }
        let paramList = [
            URLQueryItem(name: "text", value: parameters.city),
            URLQueryItem(name: "type", value: "city"),
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
        guard let data = try? jsonDecoder.decode(RawCityData.self, from: response) else {
            return nil
        }
        return data.features.map { $0.properties }
    }
}

struct CityParams {
    let city: String
    let queryLimit: Int
}

struct CityData: Codable {
    let city: String
    let latitude: Double
    let longitude: Double
    let country: String
    let countryCode: String
    let state: String?
    let stateCode: String?

    enum CodingKeys: String, CodingKey {
        case city = "city"
        case latitude = "lat"
        case longitude = "lon"
        case country = "country"
        case countryCode = "country_code"
        case state = "state"
        case stateCode = "state_code"
    }
}

struct RawCityData: Codable {
    let features: [RawCityFeature]
}

struct RawCityFeature: Codable {
    let properties: CityData
}
