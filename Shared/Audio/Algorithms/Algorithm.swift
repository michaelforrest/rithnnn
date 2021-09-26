//
//  Algorithm.swift
//  Algorithm
//
//  Created by Michael Forrest on 12/09/2021.
//

import Foundation
import AVKit

enum RecalculationFrequency:String,Codable{
    case bar
}

protocol Algorithm{
    var updatesEvery: RecalculationFrequency { get }
    
    func start(document: RithnnnDocument, player: Player, at time: AVAudioTime) throws
    
    func scheduleChanges(at time: AVAudioTime, on player: Player, document: RithnnnDocument) throws
    
    
    /*
     Concepts:
     
     Section playback
     change frequency in beats / bars
     chance of loop transition
     
     Transition
     build time
     change time (is it a big drop or a sudden cross-fade?
     effects - does it add reverb and stuff
     
     
     
     Audio Units
     reverb
     delay
     
     EffectApplication
     envelope
     
     
     Envelope
     
     
     Song structures
     A -> B -> A -> B -> C etc...
     but could also be some sort of envelope thing
     can know about groups of loops as found in rifffs
     */
}

extension Algorithm{
    func playAllLoops(rifff: Rifff, player: Player, at time: AVAudioTime) throws{
        let urls = rifff.loops.map{ player.url(for: rifff, loop: $0) }

        for (index, slot) in player.slots.enumerated(){
            if index < urls.count{
                let url:URL? = urls[index]
                if let url = url{
                    try slot.replace(
                        with: Player.AudioFileLoop(url: url, loop: rifff.loops[index]), // WARNING: memory/time-intensive
                        at: time
                    )
                }else{
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: time.hostTime)){
                        slot.clear()
                    }
                }
            }
        }
    }
    
}
