//
//  IdWrapper.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

struct IdWrapper<Inner>: Identifiable {
    let id = UUID()
    var data: Inner
}
