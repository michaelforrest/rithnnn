//
//  rithnnnApp.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI

@main
struct rithnnnApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: rithnnnDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
