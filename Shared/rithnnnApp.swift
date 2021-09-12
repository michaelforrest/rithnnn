//
//  rithnnnApp.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI

@main
struct rithnnnApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var player = Player()
    
    var body: some Scene {
        DocumentGroup(newDocument: rithnnnDocument()) { file in
            ContentView(document: file.$document, player: player).onAppear{
                RithnnnAppGroup.setLatest(
                    document: RithnnnDocumentInfo(
                        uuid: file.document.uuid.uuidString,
                        title: file.fileURL?.deletingPathExtension().lastPathComponent ?? "New Document"
                    )
                )
                RithnnnAppGroup.syncDocumentInfo()
            }
        }
    }
}
