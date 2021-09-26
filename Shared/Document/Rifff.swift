//
//  Rifff.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import Foundation

public struct Rifff:Codable,Identifiable{
    public var id: URL{
        zipURL
    }
    public struct Loop:Codable, Identifiable{
        public var id: String { filename }
        public var filename: String
        public var number: String
        public var user: String
        public var instrument: String
        public var tempo: Float
        public var dateTime: Date
        public init(filename: String, meta: String){
            self.filename = filename
            let components = meta.components(separatedBy: " - ")
            self.number = components[0]
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
