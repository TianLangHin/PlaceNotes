//
//  MapExploreView.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import MapKit
import SwiftUI

struct MapExploreView: View {

    let cityFetcher = CityFetcher()
    @State var tf = ""
    @State var resultsText = "Results"
    @State var lastQuery: [IdWrapper<CityData>] = []

    @ObservedObject var mapViewModel = MapViewModel()

    var body: some View {
        VStack {
            HStack {
                TextField("City here", text: $tf)
                Spacer()
                Button {
                    Task {
                        let params = CityParams(city: tf, queryLimit: 5)
                        let cities = await cityFetcher.fetch(params) ?? []
                        lastQuery = cities.map { IdWrapper(data: $0) }
                        tf = ""
                        resultsText = "Found: \(lastQuery.count)"
                    }
                } label: {
                    Text("Search")
                }
                .buttonStyle(.borderedProminent)
                Menu(resultsText) {
                    ForEach(lastQuery) { cityData in
                        let city = cityData.data
                        Button {
                            mapViewModel.setLocationTo(latitude: city.latitude, longitude: city.longitude)
                        } label: {
                            HStack {
                                Text("\(city.city), \(city.country)")
                            }
                        }
                    }
                }
            }
            .padding()
            HStack {
                Text("\(mapViewModel.latitude)")
                Spacer()
                Text("\(Int(mapViewModel.height))")
                Spacer()
                Text("\(mapViewModel.longitude)")
            }
            .padding()
            ZStack {
                Map(position: $mapViewModel.position) {
                    
                }
                .onMapCameraChange(frequency: .continuous) { mapUpdateCtx in
                    mapViewModel.refresh(context: mapUpdateCtx)
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
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
                .padding()
            }
        }
    }
}

#Preview {
    MapExploreView()
}
