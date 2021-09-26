//
//  SlotVie.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI

struct SlotView:View{
    @ObservedObject var slot: Player.Slot
    var body: some View{
        ProgressCircle(progress: slot.loopPosition)
            .frame(width: 100, height: 100)
            .foregroundColor(slot.loopPosition < 0 ? .orange : .green)
            .overlay(
                VStack {
                    Text(slot.playing?.loop.number ?? "").font(.largeTitle)
                    Text(slot.playing?.loop.user ?? "??").bold()
                    Text(slot.playing?.loop.instrument ?? "")
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
