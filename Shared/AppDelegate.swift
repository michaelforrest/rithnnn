//
//  AppDelegate.swift
//  FakeEndlesss
//
//  Created by Michael Forrest on 11/09/2021.
//

import UIKit
import AVKit

var userLocalDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setPreferredSampleRate(48000)
        
        RithnnnAppGroup.syncDocumentInfo()
        return true
    }
}

extension RithnnnAppGroup{
    
    static func syncDocumentInfo(){
        let dir = userLocalDir
        print("Local docs", dir)
        guard let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: []).filter({$0.pathExtension == "nnn"})  else { return }
        print("local files", files.count, files)
        
        let documents = files.map{
            RithnnnDocumentInfo(url: $0)
        }
        let data = try! JSONEncoder().encode(documents)
        defaults.setValue(data, forKey: DocListKey)
        defaults.synchronize()
        
        print("test result", listDocuments())
    }
}

extension RithnnnDocumentInfo{
    init(url: URL){
        self.title = url.deletingPathExtension().lastPathComponent
        self.uuid = try! JSONDecoder().decode(Manifest.self, from: Data(contentsOf: url.appendingPathComponent(.manifestKey))).uuid.uuidString
    }
}
