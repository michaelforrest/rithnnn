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
        let file: AVAudioFile
        init(url: URL) throws{
            self.url = url
            let file = try AVAudioFile(forReading: url)
            self.file = file
            let frameCount = AVAudioFrameCount(file.length) // from AVAudioFramePosition
            self.buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount)!
            try file.read(into: buffer)
        }
    }
    class Slot: ObservableObject, Identifiable{
        let node = AVAudioPlayerNode()
        @Published var playing: Loop?
        var id = UUID()
        
        func replace(with loop: Loop, at time: AVAudioTime?=nil){
            self.playing = loop
//            node.scheduleFile(loop.file, at: time, completionHandler: nil)
            node.scheduleBuffer(loop.buffer, at: time, options: .loops, completionHandler: nil)
            node.play()
        }
        
        func clear(){
            playing = nil
            node.stop()
        }
    }

    @Published var error: String?

    var startTime: AVAudioTime?
    
    let engine = AVAudioEngine()
    @Published var slots = (0..<9).map{ _ in Slot() }
    var document: rithnnnDocument?
    
    var debugString: String {
        engine.isRunning ?
            "\(AVAudioTime.seconds(forHostTime: slots.first?.node.lastRenderTime?.hostTime ?? 0))\n\(AVAudioTime.seconds(forHostTime: nextBarStartTime()?.hostTime ?? 0)) " : "Not Running"
    }
    
    // https://stackoverflow.com/a/52960011/191991
    func play(set: rithnnnDocument) throws {
        guard let exampleFile = set.rifffs.first?.loops.first?.url else { return }
        let exampleLoop = try Loop(url: exampleFile)
        self.document = set
        slots.forEach { slot in
            engine.attach(slot.node)
            engine.connect(slot.node, to: engine.mainMixerNode, format: exampleLoop.file.processingFormat)
        }
        engine.prepare()
        try engine.start()
        
        let startTime = AVAudioTime(hostTime: mach_absolute_time())
        slots.forEach { slot in
            slot.node.play(at: startTime)
        }
        self.startTime = startTime
        for (index, slot) in slots.enumerated(){
            let urls = set.rifffs.flatMap{ $0.loops.map{ $0.url } }
            if index < urls.count{
                let url:URL? = urls[index]
                if let url = url{
                    try slot.replace(
                        with: Loop(url: url) // WARNING: memory/time-intensive
                    )
                }
            }
        }
        objectWillChange.send()
    }
    
    func stopAndClear(){
        engine.stop()
        for slot in slots{
            slot.clear()
        }
    }
    
    func isPlaying(url: URL)->Bool{
        slots.compactMap{$0.playing?.url}.contains(url)
    }
    
    func replaceRandom(with url: URL) throws{
        if let slot = slots.first(where: { $0.playing == nil }) ?? slots.randomElement(){
            let nextStartTime = nextBarStartTime()
            slot.replace(with: try Loop(url: url), at: nextStartTime) // will be nil if nothing playing though
        }
        objectWillChange.send()
    }
    
    var startTimeInSeconds: TimeInterval{ AVAudioTime.seconds(forHostTime: startTime?.hostTime ?? 0) }
    func nextBarStartTime()->AVAudioTime?{
        guard let doc = document else { return nil }
        let secondsPlaying = AVAudioTime.seconds(forHostTime: mach_absolute_time()) - startTimeInSeconds
        let overhang = secondsPlaying.truncatingRemainder(dividingBy: doc.barLength)
        let anchor = secondsPlaying - overhang
        let nextTime = anchor + doc.barLength
        let nextHostTime = AVAudioTime.hostTime(forSeconds: nextTime + startTimeInSeconds)
        return AVAudioTime(hostTime: nextHostTime)
    }
    
    /*
     guard let startTime = startTime, let doc = document else { return nil }
     let currentTime = AVAudioTime(hostTime: mach_absolute_time()).hostTime
     let overhang = (currentTime - startTime.hostTime) % doc.barLength.hostTime
     let anchor = currentTime - overhang
     let nextTime = anchor + doc.barLength.hostTime*/
    
    func stop(url: URL){
        guard let slot = slots.first(where: { $0.playing?.url == url}) else { return }
        objectWillChange.send()
        slot.clear()
        
    }
}

extension rithnnnDocument{
    var barLength: TimeInterval{
        (60 / tempo) * 4
    }
}
