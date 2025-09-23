//
//  APIFetchable.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

protocol APIFetchable<Parameters, FetchedData> {
    associatedtype Parameters
    associatedtype FetchedData

    func fetch(_: Parameters) async -> FetchedData?
}
