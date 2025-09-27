//
//  CategoriesViewModel.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

@Observable
class CategoriesViewModel {
    func categoryNames(_ categories: [String], shorten: Bool = false) -> [String] {
        return categories.map { name in
            name
                .split(separator: ".")
                .map { component in
                    var c = String(component)
                    c.replace("_", with: " ")
                    return c.capitalized
                }
                .joined(separator: ": ")
        }
    }
}
