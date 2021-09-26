//
//  rithnnnApp.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI

@main
struct RithnnnApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var player = Player()
    
    var body: some Scene {
        DocumentGroup(newDocument: RithnnnDocument()) { file in
            DebugMasterView(document: file.$document, player: player, baseURL: file.fileURL!)
                .onAppear{
                    print("file url", file.fileURL!.absoluteString.removingPercentEncoding!)
                    RithnnnAppGroup.syncDocumentInfo()
                }
        }
    }
}
