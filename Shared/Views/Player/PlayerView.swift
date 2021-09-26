//
//  PlayerView.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var player: Player
    var debugging: Bool
    
    // FIXME: change to display link instead of 1/60
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    @State var meterLevel: CGFloat = 0
    @State var barPosition: TimeInterval = 0

    var body: some View {
        VStack{
            
            Rectangle()
                .fill(Color.green)
                .frame(maxWidth: .infinity)
                .frame(height: 2)
                .scaleEffect(x: CGFloat(barPosition), y: 1, anchor: .leading)
                
            if debugging{
                PlayerDebugView(player: player, playerDebugging: playerDebugging)
            }
        }
        .onAppear(perform: {
            try! player.play()
        })
        .onReceive(timer, perform: { _ in
            self.meterLevel = CGFloat(player.outputMeterLevel)
            self.barPosition = player.barPosition
            player.updateSlotPositions()
            self.updateDebugInfo()
        })
        .onDisappear{
            self.player.stopAndClear()
        }
    }
    
    @State var playerDebugging = ""
    func updateDebugInfo(){
        self.playerDebugging = player.debugString // maybe get this out but I don't want to spawn multiple timers to do so
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        //PlayerView()
        Text("NOT NOW")
    }
}
