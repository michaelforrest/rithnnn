//
//  rithnnnDocument.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers
import ZIPFoundation
 
struct RithnnnDocument: FileDocument{
    var filename = ""
    var manifest = Manifest()
    var container = FileWrapper(directoryWithFileWrappers: [:])
    
    public static func localURL(uuid: String)-> URL{
        userLocalDir.appendingPathComponent(uuid).appendingPathExtension("rithnnn")
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid, tempo, date, rifffs
    }
    
    var unprocessedZips = [URL]()
    
    static var readableContentTypes: [UTType] { [.set] }
    
    var queue = DispatchQueue(label: "unzipping")

    // LOAD FILE
    init(configuration: ReadConfiguration) throws {
        let data = configuration.file.fileWrappers![.manifestKey]!.regularFileContents!
        self.filename = configuration.file.filename!
        self.manifest = try JSONDecoder().decode(Manifest.self, from: data)
        self.container = configuration.file.fileWrappers![.audioKey]!
    }

    init(){}
    
    // SAVE FILE
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self.manifest)
        let manifestFileWrapper = FileWrapper(regularFileWithContents: data)
        return FileWrapper(directoryWithFileWrappers: [
            .manifestKey: manifestFileWrapper,
            .audioKey: self.container
        ])
    }
    
   
}
