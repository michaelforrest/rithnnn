//
//  PlayerDebugView.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI

struct PlayerDebugView: View {
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    @ObservedObject var player: Player
    var playerDebugging: String
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20){
            ForEach(player.slots){ slot in
                SlotView(slot: slot)
            }
        }.frame(maxWidth: .infinity).padding()
        HStack {
            Text(playerDebugging)
            Spacer()
        }.padding()
        if player.error != nil {
            Text(player.error ?? "").foregroundColor(.red)
        }
    }
}

struct PlayerDebugView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Sorry")
    }
}
