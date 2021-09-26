//
//  Manifest.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import Foundation


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
