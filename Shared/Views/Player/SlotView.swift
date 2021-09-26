//
//  SlotVie.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI

extension Player.AudioSlot{
    var stateColor: Color{
        if isMuted {
            return .gray
        }else{
            return loopPosition < 0 ? .orange : .green
        }
    }
}

struct SlotView:View{
    @ObservedObject var slot: Player.AudioSlot
    var body: some View{
        ProgressCircle(progress: slot.loopPosition)
            .frame(width: 100, height: 100)
            .foregroundColor(slot.stateColor)
            .overlay(
                VStack {
                    Text(slot.currentAudioLoop?.loop.number ?? "").font(.largeTitle)
                    Text(slot.currentAudioLoop?.loop.user ?? "??").bold()
                    Text(slot.currentAudioLoop?.loop.instrument ?? "")
                }
                .font(.caption)
                .multilineTextAlignment(.center)
                    
                , alignment: .center)
            .transformEffect(.init(scaleX: 0.6, y: 0.6))
            .onTapGesture {
                slot.clear()
            }
    }
}


struct SlotView_Previews: PreviewProvider {
    static var previews: some View {
//        SlotView()
        Text("Not right now")
    }
}
