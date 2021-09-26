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
    
    var body: some Scene {
        DocumentGroup(newDocument: RithnnnDocument()) { file in
            RithnnnDocumentView(document: file.$document, baseURL: file.fileURL!)
                .onAppear{
                    print("file url", file.fileURL!.absoluteString.removingPercentEncoding!)
                    
                    RithnnnAppGroup.syncDocumentInfo()
                    
                    RithnnnAppGroup.setLatest(
                        document: RithnnnDocumentInfo(
                            uuid: file.document.manifest.uuid.uuidString,
                            title: file.document.filename
                        )
                    )
                }
        }
    }
}
