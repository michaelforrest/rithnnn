//
//  Types.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import Foundation
import UniformTypeIdentifiers

extension String {
  static let appExtension: String = "rithnnn"
  static let versionKey: String = "Version"
  static let manifestKey: String = "Manifest.json"
  static let audioKey: String = "Audio"
}

extension UTType {
    static var set: UTType {
        UTType(exportedAs: "goodtohear.rithnnn.package", conformingTo: .package)
    }
    
}
