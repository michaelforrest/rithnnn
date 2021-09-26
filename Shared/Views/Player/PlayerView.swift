//
//  PlayerView.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var player: Player
    
    // FIXME: change to display link instead of 1/60
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    @State var playerDebugging = ""
    @State var meterLevel: CGFloat = 0
    @State var barPosition: TimeInterval = 0
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack{
            LazyVGrid(columns: columns, spacing: 20){
                ForEach(player.slots){ slot in
                    SlotView(slot: slot)
                }
            }.frame(maxWidth: .infinity).padding()
            Rectangle()
                .fill(Color.green)
                .frame(maxWidth: .infinity)
                .frame(height: 2)
                .scaleEffect(x: CGFloat(barPosition), y: 1, anchor: .leading)
                
            HStack {
                Text(playerDebugging)
                Spacer()
            }.padding()
            if player.error != nil {
                Text(player.error ?? "").foregroundColor(.red)
            }
        }
        .onAppear(perform: {
            try! player.play()
        })
        .onReceive(timer, perform: { _ in
            self.playerDebugging = player.debugString
            self.meterLevel = CGFloat(player.outputMeterLevel)
            self.barPosition = player.barPosition
            player.updateSlotPositions()
        })
        .onDisappear{
            self.player.stopAndClear()
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        //PlayerView()
        Text("NOT NOW")
    }
}
