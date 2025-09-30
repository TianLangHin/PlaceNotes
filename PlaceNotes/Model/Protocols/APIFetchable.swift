//
//  APIFetchable.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

/// This protocol defines the behaviour of all classes or structs
/// that provide a functionality to request data from an external API.
///
/// It requires two generic associated types.
/// `Parameters` is the data type that contains the request parameters to be given to the API call.
/// `FetchedData` is the data type that will be returned from the API.
protocol APIFetchable<Parameters, FetchedData> {
    associatedtype Parameters
    associatedtype FetchedData

    /// This protocol requires that a `fetch` function be implemented.
    /// It is marked `async` since external API calls are asynchronous from the app's internal process.
    /// An optional `FetchedData` instance is returned since the API call might fail.
    func fetch(_: Parameters) async -> FetchedData?
}
