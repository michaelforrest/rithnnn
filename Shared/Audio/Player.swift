//
//  Player.swift
//  FakeEndlesss
//
//  Created by Michael Forrest on 11/09/2021.
//

import Foundation
import AVKit


class Player: ObservableObject{
    struct Loop{
        let url: URL
        let buffer: AVAudioPCMBuffer
        init(url: URL) throws{
            self.url = url
            let file = try AVAudioFile(forReading: url)
            let frameCount = AVAudioFrameCount(file.length) // from AVAudioFramePosition
            self.buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount)!
            try file.read(into: buffer)
        }
    }
    class Slot: ObservableObject, Identifiable{
        let node = AVAudioPlayerNode()
        @Published var playing: Loop?
        var id = UUID()
        
        func replace(with loop: Loop){
            self.playing = loop
            node.scheduleBuffer(loop.buffer, at: nil, options: .loops, completionHandler: nil)
            node.play()
        }
        
        func clear(){
            playing = nil
            node.stop()
        }
    }

    @Published var error: String?

    
    let engine = AVAudioEngine()
    @Published var slots = (0..<9).map{ _ in Slot() }
    
    func play(set: RithnnnSet) throws {
        slots.forEach { slot in
            engine.attach(slot.node)
            engine.connect(slot.node, to: engine.mainMixerNode, format: nil)
        }
        
        engine.prepare()
        try engine.start()
        
        let startTime = AVAudioTime(hostTime: mach_absolute_time())
        slots.forEach { slot in
            slot.node.play(at: startTime)
        }
        
        for (index, slot) in slots.enumerated(){
            if let url = set.audioFileURLs?[index]{
                try slot.replace(
                    with: Loop(url: url) // WARNING: memory/time-intensive
                )
            }
        }
        objectWillChange.send()
    }
    
    func isPlaying(url: URL)->Bool{
        slots.compactMap{$0.playing?.url}.contains(url)
    }
    
    func replaceRandom(with url: URL) throws{
        if let slot = slots.first(where: { $0.playing == nil }){
            slot.replace(with: try Loop(url: url))
        }else if let slot = slots.randomElement() {
            slot.replace(with: try Loop(url: url))
        }
        objectWillChange.send()
    }
    
    func stop(url: URL){
        guard let slot = slots.first(where: { $0.playing?.url == url}) else { return }
        objectWillChange.send()
        slot.clear()
        
    }
}
