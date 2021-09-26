//
//  ToggleOneSlotEveryBar.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import Foundation
import AVKit

class ToggleOneSlotEveryBar: ObservableObject, Algorithm{
    var updatesEvery: RecalculationFrequency = .bar
    
    @Published var currentRifff: Rifff?
    @Published var changeCountdown = 32
    
    func start(document: RithnnnDocument, player: Player, at time: AVAudioTime) throws{
        let rifff = document.manifest.rifffs.first!
        try playAllLoops(rifff: rifff, player: player, at: time)
        
        self.currentRifff = rifff
    }
    
    func scheduleChanges(at time: AVAudioTime, on player: Player, document: RithnnnDocument) throws{
        changeCountdown -= 1
        if changeCountdown <= 0{
            changeCountdown = [8,16,32].randomElement()!
            if let rifff = document.manifest.rifffs.randomElement(){
                DispatchQueue.main.async {
                    try? self.playAllLoops(rifff: rifff, player: player, at: time)
                }
                self.currentRifff = rifff
            }
        }else if changeCountdown % 4 == 0{
            player.run(at: time) {
                player.slots.filter({ $0.currentAudioLoop != nil }).randomElement()?.toggleMuted()
            }
        }
    }
}
