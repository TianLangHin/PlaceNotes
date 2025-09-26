//
//  DateFormatExtension.swift
//  PlaceNotes
//
//  Created by Tian Lang Hin on 23/9/2025.
//

import Foundation

extension DateFormatter {
    // A convenience static function that creates a `DateFormatter` instance
    // that formats dates to the ISO 8601 format.
    static func iso() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }
}
