//
//  Loop.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import Foundation
import AVKit
extension Player{
    struct Loop{
        let url: URL
        let buffer: AVAudioPCMBuffer
        let file: AVAudioFile
        let loop: Rifff.Loop
        let lengthInSeconds: TimeInterval
        init(url: URL, loop: Rifff.Loop) throws{
            self.url = url
            self.loop = loop
            let file = try AVAudioFile(forReading: url)
            self.file = file
            let frameCount = AVAudioFrameCount(file.length) // from AVAudioFramePosition
            self.buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount)!
            try file.read(into: buffer)
            self.lengthInSeconds = buffer.lengthInSeconds
        }
    }
}
