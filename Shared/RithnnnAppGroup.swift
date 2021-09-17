//
//  RithnnnAppGroup.swift
//  ShareExtension
//
//  Created by Michael Forrest on 12/09/2021.
//

import UIKit

struct RithnnnDocumentInfo:Codable, Identifiable{
    var id: String { uuid }
    let uuid: String
    let title: String
}
fileprivate let LatestDocKey = "LatestDoc"

struct RithnnnAppGroup{
    static var DocListKey = "DocumentsList"
    
    static let defaults = UserDefaults(suiteName: "group.rithnnn")!
    
    static var containerURL: URL{
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.rithnnn")!
    }
    
    static func inbox(uuid: UUID)->URL{
        containerURL.appendingPathComponent("Inbound").appendingPathComponent(uuid.uuidString)
    }
    
    static func createInbox(uuid: UUID){
        let fileManager = FileManager.default
        let inbox = self.inbox(uuid: uuid)
        try? fileManager.createDirectory(at: inbox, withIntermediateDirectories: true, attributes: nil)
        
    }
    
    static func setLatest(document: RithnnnDocumentInfo){
        let data = try! JSONEncoder().encode(document)
        defaults.setValue(data, forKey: LatestDocKey)
        defaults.synchronize()
        
    }
    static func getLatestDocument()->RithnnnDocumentInfo?{
        if let data = defaults.data(forKey: LatestDocKey),
           let document = try? JSONDecoder().decode(RithnnnDocumentInfo.self, from: data) {
            return document
        }else{
            return nil
        }
    }
    static func listDocuments()->[RithnnnDocumentInfo]{
        if let data = defaults.data(forKey: DocListKey),
           let documents = try? JSONDecoder().decode([RithnnnDocumentInfo].self, from: data){
            return documents
        }else{
            return []
        }
    }
}
