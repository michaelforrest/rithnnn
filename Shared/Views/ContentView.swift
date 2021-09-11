//
//  ContentView.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI

struct SlotView:View{
    @ObservedObject var slot: Player.Slot
    var body: some View{
        Circle()
            .stroke()
            .frame(width: 100, height: 100)
            .foregroundColor(.red)
            
            .overlay(
                Text(slot.playing?.url.lastPathComponent ?? "-")
                    .bold().font(.caption)
                    .multilineTextAlignment(.center)
                    
                , alignment: .center)
            .onTapGesture {
                slot.clear()
            }
    }
}

struct ContentView: View {
    @Binding var document: rithnnnDocument
    @ObservedObject var player: Player
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 20){
                ForEach(player.slots){ slot in
                    SlotView(slot: slot)
                }
            }.frame(maxWidth: .infinity).padding()
            List {
                if player.error != nil {
                    Text(player.error ?? "").foregroundColor(.red)
                }
                
                ForEach(document.unprocessedZips, id: \.self){ url in
                    HStack{
                        Image(systemName: "doc.zipper")
                        Text(url.lastPathComponent)
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
                ForEach(document.set.audioFileURLs!, id: \.self){ url in
                    HStack {
                        Image(systemName: "waveform.circle")
                        Text(url.lastPathComponent)
                        Spacer()
                        if player.isPlaying(url: url){
                            Image(systemName: "speaker.wave.2.circle")
                        }
                    }.onTapGesture {
                        if player.isPlaying(url: url){
                            player.stop(url: url)
                        }else{
                            try? player.replaceRandom(with: url)
                        }
                    }
                }
            }
            .onAppear{
                try? self.player.play(set: document.set)
        }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(rithnnnDocument()), player: Player())
    }
}
