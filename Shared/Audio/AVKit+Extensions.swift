//
//  AVKit+Extensions.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import Foundation
import AVKit

extension AVAudioPCMBuffer{
    var lengthInSeconds:TimeInterval{
        let frameCount = Double(frameLength)
        let sampleRate = format.sampleRate
        return TimeInterval(frameCount / sampleRate)
    }
}
