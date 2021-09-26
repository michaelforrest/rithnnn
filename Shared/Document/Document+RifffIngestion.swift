//
//  File.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import Foundation

extension RithnnnDocument{
    func processInboundFiles(onStartProcessing: @escaping (_ url: URL)->Void, emitRifff: @escaping (_ rifff:Rifff)->Void){
        let fileManager = FileManager.default
        let inbox = RithnnnAppGroup.inbox(uuid: manifest.uuid)
        try? fileManager.createDirectory(at: inbox, withIntermediateDirectories: true, attributes: nil)
        
        print("Looking for ZIP files in container", inbox)
        
        let files = try! fileManager.contentsOfDirectory(at: inbox, includingPropertiesForKeys: nil, options: []).filter{ $0.lastPathComponent.hasSuffix(".zip")}
        print("Found", files.count, "zip files")
        
        for url in files{
            if let _ = manifest.rifffs.firstIndex(where: {$0.zipURL == url}){
            }else{
                let dirName = url.deletingPathExtension().lastPathComponent
                let tempDir = fileManager.temporaryDirectory.appendingPathComponent(dirName)
                
                onStartProcessing(url)
                queue.async {
                    try? fileManager.unzipItem(at: url, to: tempDir)
                    if let audioFiles = try? fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil, options: []){
                        let fileWrapper = FileWrapper(directoryWithFileWrappers: audioFiles.reduce([String:FileWrapper](), { (result, url) -> [String:FileWrapper] in
                            result.merging([url.lastPathComponent: try! FileWrapper(url: url, options: .immediate)], uniquingKeysWith: {a,_ in a})
                        }))
                        fileWrapper.preferredFilename = tempDir.lastPathComponent
                        let rifff = Rifff(zipURL: url, tempDir: tempDir, dirName: dirName, loops: audioFiles.map{ audioFileURL -> Rifff.Loop in
                            Rifff.Loop(filename: audioFileURL.lastPathComponent, meta: audioFileURL.deletingPathExtension().lastPathComponent)
                        })
                        DispatchQueue.main.async {
                            self.container.addFileWrapper(fileWrapper)
                            emitRifff(rifff)
                        }
                    }
                }

            }
        }
    }
}
