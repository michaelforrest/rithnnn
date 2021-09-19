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
        let loop: Rifff.Loop
        init(url: URL, loop: Rifff.Loop) throws{
            self.url = url
            self.loop = loop
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
    let TapBufferFrames:AVAudioFrameCount = 512
    
    
    let engine = AVAudioEngine()
    @Published var slots = (0..<9).map{ _ in Slot() }
    var outputMeterLevel: Float = 0
    var timeInBars: TimeInterval{
        (AVAudioTime.seconds(forHostTime: mach_absolute_time()) - self.startTimeInSeconds) / (document?.barLength ?? 1.0)
    }
    var barPosition: TimeInterval{
        self.timeInBars.truncatingRemainder(dividingBy: 1.0)
    }
    
    var document: rithnnnDocument?
    
    var debugString: String {
        engine.isRunning ?
            "\(timeInBars)\n\(AVAudioTime.seconds(forHostTime: slots.first?.node.lastRenderTime?.hostTime ?? 0))\n\(AVAudioTime.seconds(forHostTime: nextBarStartTime()?.hostTime ?? 0))" : "Not Running"
    }
    
    func url(_ baseURL:URL, rifff: Rifff, loop: Rifff.Loop)->URL{
        baseURL
            .appendingPathComponent("Audio")
            .appendingPathComponent(rifff.dirName)
            .appendingPathComponent(loop.filename)
    }
    
    // https://stackoverflow.com/a/52960011/191991
    func play(set: rithnnnDocument, baseURL: URL) throws {
        guard let firstRifff = set.manifest.rifffs.first,
              let firstLoop = firstRifff.loops.first,
              let fileWrapper = set.container.fileWrappers?[firstRifff.dirName]?.fileWrappers?[firstLoop.filename]
              else { return }
        engine.stop()
        let exampleLoop = try Loop(url: self.url(baseURL, rifff: firstRifff, loop: firstLoop), loop: firstLoop)
        self.document = set
        slots.forEach { slot in
            engine.attach(slot.node)
            engine.connect(slot.node, to: engine.mainMixerNode, format: exampleLoop.file.processingFormat)
        }
        
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.mainMixerNode.removeTap(onBus: 0)
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: TapBufferFrames, format: format) { buffer, time in
            let arraySize = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count:arraySize))
            let total = samples.reduce(0, +)
            self.outputMeterLevel = total / Float(buffer.frameLength)
            
        }
        engine.prepare()
        try engine.start()
        
        let startTime = nextBarStartTime() ?? AVAudioTime(hostTime: mach_absolute_time())
        slots.forEach { slot in
            slot.node.play(at: startTime)
        }
        self.startTime = startTime
        let flatLoops = set.manifest.rifffs.flatMap{$0.loops}
        for (index, slot) in slots.enumerated(){
            let urls = set.manifest.rifffs.flatMap{ rifff in rifff.loops.map{ self.url(baseURL, rifff: rifff, loop: $0) } }
            if index < urls.count{
                let url:URL? = urls[index]
                if let url = url{
                    try slot.replace(
                        with: Loop(url: url, loop: flatLoops[index]) // WARNING: memory/time-intensive
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
    func isPlaying(loop: Rifff.Loop)->Bool{
        false
    }
    func isPlaying(url: URL)->Bool{
        slots.compactMap{$0.playing?.url}.contains(url)
    }
    
    func replaceRandom(with loop: Rifff.Loop, rifff: Rifff, baseURL: URL) throws{
        if let slot = slots.first(where: { $0.playing == nil }) ?? slots.randomElement(){
            let nextStartTime = nextBarStartTime()
            slot.replace(with: try Loop(url: url(baseURL, rifff: rifff, loop: loop), loop: loop), at: nextStartTime) // will be nil if nothing playing though
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
    func stop(loop: Rifff.Loop){
        
    }
}

extension rithnnnDocument{
    var barLength: TimeInterval{
        (60 / manifest.tempo) * 4
    }
}
