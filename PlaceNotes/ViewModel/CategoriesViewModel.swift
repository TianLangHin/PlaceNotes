//
//  CategoriesViewModel.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 27/9/2025.
//

import SwiftUI

/// This is a lightweight ViewModel that allows all appropriate `View`s
/// to display all the associated categories of a particular `Place` or `LocationData` instance
/// in an interpretable and user-friendly fashion.
@Observable
class CategoriesViewModel {
    /// Converts every category name into a human-interpretable format,
    /// with underscores (`_`) converted to whitespace and dots (`.`) converted to colon separators.
    /// This converts category strings given by [the Geoapify API](https://apidocs.geoapify.com/docs/places/#categories)
    /// into a more readable format.
    func categoryNames(_ categories: [String]) -> [String] {
        return categories.map { name in
            // Dots represent new words. Underscores represent whitespace.
            name
                .split(separator: ".")
                .map { component in
                    // Additionally, since every string is lowercased,
                    // every word is capitalised to make it more intuitive to the user.
                    var c = String(component)
                    c.replace("_", with: " ")
                    return c.capitalized
                }
                .joined(separator: ": ")
        }
    }
}
