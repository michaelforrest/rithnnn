//
//  AppDelegate.swift
//  FakeEndlesss
//
//  Created by Michael Forrest on 11/09/2021.
//

import UIKit
import AVKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        
        return true
    }
}
