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
        UTType(exportedAs: "goodtohear.rithnnn.set")
    }
}

public struct Rifff:Codable,Identifiable{
    public var id: URL{
        zipURL
    }
    public struct Loop:Codable, Identifiable{
        public var id: URL { url }
        public var url: URL
        public var user: String
        public var instrument: String
        public var tempo: Float
        public var dateTime: Date
        public init(url: URL){
            self.url = url
            let components = url.deletingPathExtension().lastPathComponent.components(separatedBy: " - ")
            self.user = components[1]
            self.instrument = components[2]
            self.tempo = Float(components[3].replacingOccurrences(of: "BPM", with: "")) ?? 120
            //  2021-09-11-14-43
            let dateComponents = components[4].split(separator: "-").compactMap{Int($0)}
            self.dateTime = Calendar.current.date(
                from: DateComponents(
                    year: dateComponents[0], month: dateComponents[1], day: dateComponents[2], hour: dateComponents[3], minute: dateComponents[4])
            ) ?? Date()
        }
    }
    public var zipURL: URL
    public var loops: [Loop]
    
}

struct rithnnnDocument: FileDocument, Codable {
    var uuid = UUID()
    var tempo: TimeInterval = 140
    var date = Date()
    var rifffs = [Rifff]()
    
    
    public static func localURL(uuid: String)-> URL{
        userLocalDir.appendingPathComponent(uuid).appendingPathExtension("rithnnn")
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid, tempo, date, rifffs
    }
    
    var unprocessedZips = [URL]()
    
    private var containerURL: URL { FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.rithnnn")! }
    private var inbox: URL {containerURL.appendingPathComponent("Inbound").appendingPathComponent(uuid.uuidString)}
    private var rifffsContainer: URL { containerURL.appendingPathComponent(uuid.uuidString).appendingPathComponent("Rifffs")}
    
    static var readableContentTypes: [UTType] { [.set] }
    
    private var queue = DispatchQueue(label: "unzipping")

    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents!
        self = try JSONDecoder().decode(Self.self, from: data)
        
    }
    init(){ // first creation
        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: inbox, withIntermediateDirectories: true, attributes: nil)
        
        try! fileWrapper().write(to: rithnnnDocument.localURL(uuid: uuid.uuidString), options: .atomic, originalContentsURL: nil)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        return .init(regularFileWithContents: data)
    }
    
    func processInboundFiles(onStartProcessing: @escaping (_ url: URL)->Void, emitRifff: @escaping (_ rifff:Rifff)->Void){
        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: inbox, withIntermediateDirectories: true, attributes: nil)
        
        print("looking in container", inbox)
        
        let files = try! fileManager.contentsOfDirectory(at: inbox, includingPropertiesForKeys: nil, options: []).filter{ $0.lastPathComponent.hasSuffix(".zip")}
        print("Found", files.count, "zip files")
        for url in files{
            if let _ = rifffs.firstIndex(where: {$0.zipURL == url}){
            }else{
                let container = rifffsContainer.appendingPathComponent(url.deletingPathExtension().lastPathComponent)
                onStartProcessing(url)
                queue.async {
                    try? fileManager.unzipItem(at: url, to: container)
                    if let audioFiles = try? fileManager.contentsOfDirectory(at: container, includingPropertiesForKeys: nil, options: []){
                        let rifff = Rifff(zipURL: url, loops: audioFiles.map{ audioFileURL -> Rifff.Loop in
                            Rifff.Loop(url: audioFileURL)
                        })
                        DispatchQueue.main.async {
                            emitRifff(rifff)
                        }
                    }
                }
                
            }
        }
    }
}
