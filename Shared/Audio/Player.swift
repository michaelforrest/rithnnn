//
//  Player.swift
//  FakeEndlesss
//
//  Created by Michael Forrest on 11/09/2021.
//

import Foundation
import AVKit

class Player: ObservableObject{
    @Published var error: String?

    var startTime: AVAudioTime?
    let TapBufferFrames:AVAudioFrameCount = 512
        
    let engine = AVAudioEngine()
    @Published var slots = (0..<8).map{ _ in Slot() }
    
    var outputMeterLevel: Float = 0
    
    private var document: RithnnnDocument
    private var baseURL: URL
    
    var debugString: String {
        engine.isRunning ?
        "\(timeInBars(hostTime: mach_absolute_time()))\n\(AVAudioTime.seconds(forHostTime: slots.first?.node.lastRenderTime?.hostTime ?? 0))\n\(AVAudioTime.seconds(forHostTime: nextBarStartTime(hostTime: mach_absolute_time())?.hostTime ?? 0))" : "Not Running"
    }
    

    init(document: RithnnnDocument, baseURL: URL){
        self.document = document
        self.baseURL = baseURL
    }
    
    func url(for rifff: Rifff, loop: Rifff.Loop)->URL{
        baseURL
            .appendingPathComponent("Audio")
            .appendingPathComponent(rifff.dirName)
            .appendingPathComponent(loop.filename)
    }
    
    func play() throws {
        guard let firstRifff = document.manifest.rifffs.first,
              let firstLoop = firstRifff.loops.first else { return }
        
        engine.stop()
        // take a random loop, assuming all loops have the same audio settings, just to get the engine set up correctly.
        let exampleLoop = try Loop(url: self.url(for: firstRifff, loop: firstLoop), loop: firstLoop)
        slots.forEach { slot in
            engine.attach(slot.node)
            engine.connect(slot.node, to: engine.mainMixerNode, format: exampleLoop.file.processingFormat) // so that's where we get the audio format
        }
        
        let busFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.mainMixerNode.removeTap(onBus: 0)
        
        let barLengthInFrames:Int64 = Int64(document.barLength * exampleLoop.file.processingFormat.sampleRate)
        
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: TapBufferFrames, format: busFormat) { buffer, time in
            let arraySize = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count:arraySize))
            let total = samples.reduce(0, +)
            self.outputMeterLevel = Float(total) / Float(buffer.frameLength)
            
            if let startTime = self.startTime {
                if (time.sampleTime - startTime.sampleTime) % barLengthInFrames < Int64(buffer.frameLength){
//                    print("SCHEDULE NEXT BAR CHANGES START:",startTime.sampleTime, "BAR", barLengthInFrames, "BUF",buffer.frameLength,"TIME", time.sampleTime, "RESULT", (time.sampleTime - startTime.sampleTime) % barLengthInFrames)
                    self.scheduleBarChanges()
                }
            }
        }
        
        engine.prepare()
        try engine.start()
        
        try playFirstFewLoops()
        objectWillChange.send()
    }
    
    func timeInBars(hostTime: UInt64)-> TimeInterval{
        (AVAudioTime.seconds(forHostTime: hostTime) - self.startTimeInSeconds) / (document.barLength)
    }
    func barPosition(hostTime: UInt64) -> TimeInterval{
        self.timeInBars(hostTime: hostTime).truncatingRemainder(dividingBy: 1.0)
    }
    
    
    func playFirstFewLoops() throws{
        let startTime = nextBarStartTime(hostTime: mach_absolute_time()) ?? AVAudioTime(hostTime: mach_absolute_time())
        slots.forEach { slot in
            slot.node.play(at: startTime)
        }
        self.startTime = startTime
        let flatLoops = document.manifest.rifffs.flatMap{$0.loops}
        for (index, slot) in slots.enumerated(){
            let urls = document.manifest.rifffs.flatMap{ rifff in rifff.loops.map{ self.url(for: rifff, loop: $0) } }
            if index < urls.count{
                let url:URL? = urls[index]
                if let url = url{
                    try slot.replace(
                        with: Loop(url: url, loop: flatLoops[index]), // WARNING: memory/time-intensive
                        at: startTime
                    )
                }
            }
        }
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
    
    func replaceRandom(with loop: Rifff.Loop, rifff: Rifff) throws{
        if let slot = slots.first(where: { $0.playing == nil }) ?? slots.randomElement(){
            let nextStartTime = nextBarStartTime(hostTime: mach_absolute_time())
            slot.replace(with: try Loop(url: url(for: rifff, loop: loop), loop: loop), at: nextStartTime!) // will be nil if nothing playing though
        }
        objectWillChange.send()
    }
    
    var startTimeInSeconds: TimeInterval{ AVAudioTime.seconds(forHostTime: startTime?.hostTime ?? 0) }
    
    func nextBarStartTime(hostTime: UInt64)->AVAudioTime?{
        let doc = document
        let secondsPlaying = AVAudioTime.seconds(forHostTime: hostTime) - startTimeInSeconds
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
    
    func updateSlotPositions(){
        for slot in slots{
            slot.upddateLoopPosition()
        }
    }
    
    func scheduleBarChanges(){
        
    }
    
}

extension RithnnnDocument{
    var barLength: TimeInterval{
        (60 / manifest.tempo) * 4
    }
}
