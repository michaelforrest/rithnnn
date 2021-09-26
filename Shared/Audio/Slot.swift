//
//  Slot.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import Foundation
import AVKit

extension Player{
    class Slot: ObservableObject, Identifiable{
        let node = AVAudioPlayerNode()
        @Published var playing: Loop?
        @Published var loopPosition: TimeInterval = 0
        var id = UUID()
        var startTime: AVAudioTime?
        
        func replace(with loop: Loop, at time: AVAudioTime){
            self.playing = loop
            self.startTime = time
//            node.scheduleFile(loop.file, at: time, completionHandler: nil)
            node.scheduleBuffer(loop.buffer, at: time, options: .loops, completionHandler: nil)
            node.play()
        }
        
        func clear(){
            playing = nil
            node.stop()
        }
        func upddateLoopPosition(){
            if let loop = playing, let startTime = startTime{
                loopPosition = ( (AVAudioTime.seconds(forHostTime: mach_absolute_time()) - AVAudioTime.seconds(forHostTime: startTime.hostTime)) / loop.lengthInSeconds).truncatingRemainder(dividingBy: 1.0)
            }else{
                loopPosition = 0
            }
        }
    }
}
