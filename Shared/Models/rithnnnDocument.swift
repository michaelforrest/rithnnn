//
//  rithnnnDocument.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers
import ZIPFoundation

extension UTType {
    static var set: UTType {
        UTType(importedAs: "goodtohear.rithnnn.set")
    }
}

struct RithnnnSet: Codable{
    var tempo: Float = 140
    var date = Date()
    var processedZips = [URL]()
    var audioFileURLs:[URL]?
}

class rithnnnDocument: FileDocument, ObservableObject {
    var set = RithnnnSet()
    @Published var unprocessedZips = [URL]()
    
    
    private var containerURL: URL { FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.rithmmm")! }
    private var inbox: URL {containerURL.appendingPathComponent("Inbound")}
    private var audioContainer: URL { containerURL.appendingPathComponent("AudioFiles")}
    
    static var readableContentTypes: [UTType] { [.set] }

    init(){}
    
    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        do {
            self.set = try JSONDecoder().decode(RithnnnSet.self, from: data)
        }catch{
            print("error!", error)
        }
        processInboundFiles()
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(set)
        return .init(regularFileWithContents: data)
    }
    
    func processInboundFiles(){
        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: inbox, withIntermediateDirectories: true, attributes: nil)
        
        let files = try! fileManager.contentsOfDirectory(at: inbox, includingPropertiesForKeys: nil, options: [])
        unprocessedZips = files
        
        for url in files{
            if let index = set.processedZips.firstIndex(of: url){
                unprocessedZips.remove(at: index)
            }else{
                try? fileManager.unzipItem(at: url, to: audioContainer)
                set.processedZips.append(url)
            }
        }
        set.audioFileURLs = try? fileManager.contentsOfDirectory(at: audioContainer, includingPropertiesForKeys: nil, options: [])
    }
}
