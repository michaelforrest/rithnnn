//
//  Slot.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import Foundation
import AVKit

extension Player{
    class AudioSlot: ObservableObject, Identifiable{
        let node = AVAudioPlayerNode()
        @Published var currentAudioLoop: AudioFileLoop?
        @Published var loopPosition: TimeInterval = 0
        @Published var isMuted = false
        var id = UUID()
        var startTime: AVAudioTime?
        
        func replace(with loop: AudioFileLoop, at time: AVAudioTime){
            self.currentAudioLoop = loop
            self.startTime = time
//            node.scheduleFile(loop.file, at: time, completionHandler: nil)
            node.scheduleBuffer(loop.buffer, at: time, options: .loops, completionHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: time.hostTime)) {
                self.toggleMuted(muted: false)
            }
            node.play()
        }
        
        func clear(){
            currentAudioLoop = nil
            node.stop()
        }
        func upddateLoopPosition(){
            if let loop = currentAudioLoop, let startTime = startTime{
                loopPosition = ( (AVAudioTime.seconds(forHostTime: mach_absolute_time()) - AVAudioTime.seconds(forHostTime: startTime.hostTime)) / loop.lengthInSeconds).truncatingRemainder(dividingBy: 1.0)
            }else{
                loopPosition = 0
            }
        }
        func toggleMuted(muted: Bool?=nil){
            if let muted = muted{
                isMuted = muted
            }else{
                isMuted.toggle()
            }
            node.volume = isMuted ? 0 : 1
        }
    }
}
