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
    
    let timer = Timer.publish(every: 0.01666, on: .main, in: .common).autoconnect()
    @State var playerDebugging = ""
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 20){
                ForEach(player.slots){ slot in
                    SlotView(slot: slot)
                }
            }.frame(maxWidth: .infinity).padding()
            HStack {
                Text(playerDebugging)
                Spacer()
            }.padding()
            List {
                if player.error != nil {
                    Text(player.error ?? "").foregroundColor(.red)
                }
                ForEach(document.unprocessedZips, id: \.self){ url in
                    HStack{
                        Image(systemName: "doc.zipper")
                        Text(url.lastPathComponent)
                        Spacer()
                        ProgressView()
                    }
                }
                ForEach(document.rifffs){ rifff in
                    HStack{
                        Image(systemName: "doc.zipper")
                        Text(rifff.zipURL.lastPathComponent)
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                    .foregroundColor(.white)
                    .background(Color.gray)
                    ForEach(rifff.loops) { loop in
                        HStack {
                            Image(systemName: "waveform.circle")
                            Text(loop.url.lastPathComponent)
                            Spacer()
                            if player.isPlaying(url: loop.url){
                                Image(systemName: "speaker.wave.2.circle")
                            }
                        }.onTapGesture {
                            if player.isPlaying(url: loop.url){
                                player.stop(url: loop.url)
                            }else{
                                try? player.replaceRandom(with: loop.url)
                            }
                        }
                    }
                    
                }
                TextField("UUID", text: Binding.constant(document.uuid.uuidString))
            }
            .onReceive(timer, perform: { _ in
                playerDebugging = player.debugString
            })
            .onAppear{
                document.processInboundFiles(onStartProcessing: {url in
                    document.unprocessedZips.append(url)
                }){ rifff in
                    withAnimation {
                        document.rifffs.append(rifff)
                        if let index =  document.unprocessedZips.firstIndex(of: rifff.zipURL){
                            document.unprocessedZips.remove(at:index)
                        }
                        try? player.play(set: document)
                    }
                }
                try? self.player.play(set: document)
            }
            .onDisappear{
                self.player.stopAndClear()
            }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(rithnnnDocument()), player: Player())
    }
}
