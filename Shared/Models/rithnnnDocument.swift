//
//  rithnnnDocument.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers
import ZIPFoundation

extension String {
  static let appExtension: String = "rithnnn"
  static let versionKey: String = "Version"
  static let manifestKey: String = "Manifest"
  static let audioKey: String = "Audio"
}

extension UTType {
    static var set: UTType {
        UTType(exportedAs: "goodtohear.rithnnn.package", conformingTo: .package)
    }
    
}


public struct Rifff:Codable,Identifiable{
    public var id: URL{
        zipURL
    }
    public struct Loop:Codable, Identifiable{
        public var id: String { filename }
        public var filename: String
        public var user: String
        public var instrument: String
        public var tempo: Float
        public var dateTime: Date
        public init(filename: String){
            self.filename = filename
            let components = filename.components(separatedBy: " - ")
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
    public var tempDir: URL?
    public var dirName: String
    public var loops: [Loop]
    
    var fileWrapper: FileWrapper{
        FileWrapper(directoryWithFileWrappers: [:])
    }
}

struct Manifest: Codable{
    var uuid = UUID()
    var tempo: TimeInterval = 140
    var date = Date()
    var rifffs = [Rifff]()
    
    var fileWrapper: FileWrapper{
        FileWrapper(directoryWithFileWrappers: rifffs.reduce([String:FileWrapper](), { partialResult, rifff in
            partialResult.merging([rifff.dirName: rifff.fileWrapper], uniquingKeysWith: {a,_ in a})
        }))
    }
   
}

struct rithnnnDocument: FileDocument{
    var manifest = Manifest()
    var container: FileWrapper?
    
    public static func localURL(uuid: String)-> URL{
        userLocalDir.appendingPathComponent(uuid).appendingPathExtension("rithnnn")
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid, tempo, date, rifffs
    }
    
    var unprocessedZips = [URL]()
    
    static var readableContentTypes: [UTType] { [.set] }
    
    private var queue = DispatchQueue(label: "unzipping")

    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.fileWrappers![.manifestKey]!.regularFileContents!
        self.manifest = try JSONDecoder().decode(Manifest.self, from: data)
        self.container = configuration.file
    }

    init(){}
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self.manifest)
        let manifestFileWrapper = FileWrapper(regularFileWithContents: data)
        
        return FileWrapper(directoryWithFileWrappers: [
            .manifestKey: manifestFileWrapper,
            .audioKey: manifest.fileWrapper
        ])
    }
    
    func processInboundFiles(onStartProcessing: @escaping (_ url: URL)->Void, emitRifff: @escaping (_ rifff:Rifff)->Void){
        let fileManager = FileManager.default
        let inbox = RithnnnAppGroup.inbox(uuid: manifest.uuid)
        try? fileManager.createDirectory(at: inbox, withIntermediateDirectories: true, attributes: nil)
        
        print("looking in container", inbox)
        
        let files = try! fileManager.contentsOfDirectory(at: inbox, includingPropertiesForKeys: nil, options: []).filter{ $0.lastPathComponent.hasSuffix(".zip")}
        print("Found", files.count, "zip files")
        for url in files{
            if let _ = manifest.rifffs.firstIndex(where: {$0.zipURL == url}){
            }else{
                let dirName = url.deletingPathExtension().lastPathComponent
                let tempDir = fileManager.temporaryDirectory.appendingPathComponent(dirName)
                let fileWrapper = FileWrapper(directoryWithFileWrappers: [:])
                onStartProcessing(url)
                queue.async {
                    try? fileManager.unzipItem(at: url, to: tempDir)
                    if let audioFiles = try? fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil, options: []){
                        audioFiles.forEach { url in
                            fileWrapper.addFileWrapper(try! FileWrapper(url: url, options: []))
                        }
                        let rifff = Rifff(zipURL: url, tempDir: tempDir, dirName: dirName, loops: audioFiles.map{ audioFileURL -> Rifff.Loop in
                            Rifff.Loop(filename: audioFileURL.lastPathComponent)
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
