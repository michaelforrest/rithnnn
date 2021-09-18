//
//  Algorithm.swift
//  Algorithm
//
//  Created by Michael Forrest on 12/09/2021.
//

import Foundation

struct Algorithm:Codable{
    
    enum RecalculationFrequency:String,Codable{
        case bar
    }
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
    var updatesEvery: RecalculationFrequency = .bar
    
}
