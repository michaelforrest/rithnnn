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

struct RifffListing: View{
    var rifff: Rifff
    var player: Player
    var baseURL: URL
    var body: some View{
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
                Text(loop.filename)
                Spacer()
                if player.isPlaying(loop: loop){
                    Image(systemName: "speaker.wave.2.circle")
                }
            }.onTapGesture {
                if player.isPlaying(loop: loop){
                    player.stop(loop: loop)
                }else{
                    try? player.replaceRandom(with: loop,rifff: rifff, baseURL: baseURL)
                }
            }
        }
        
    }
}

struct ContentView: View {
    @Binding var document: rithnnnDocument
    @ObservedObject var player: Player
    var baseURL: URL
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    let timer = Timer.publish(every: 0.01666, on: .main, in: .common).autoconnect()
    @State var playerDebugging = ""
    @State var meterLevel: CGFloat = 0
    
    var body: some View {
        let rifffs = document.manifest.rifffs
        return VStack {
            LazyVGrid(columns: columns, spacing: 20){
                ForEach(player.slots){ slot in
                    SlotView(slot: slot)
                }
            }.frame(maxWidth: .infinity).padding()
            Rectangle()
                .fill(Color.green)
                .frame(width: 150 * (meterLevel + 1), height: 2)
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
                ForEach(rifffs){ rifff in
                    RifffListing(rifff: rifff, player: player, baseURL: baseURL)
                }
                TextField("UUID", text: Binding.constant(document.manifest.uuid.uuidString))
            }
            .onReceive(timer, perform: { _ in
                playerDebugging = player.debugString
                meterLevel = CGFloat(player.outputMeterLevel)
            })
            .onAppear{
                RithnnnAppGroup.setLatest(
                    document: RithnnnDocumentInfo(
                        uuid: document.manifest.uuid.uuidString,
                        title: document.filename
                    )
                )
                document.processInboundFiles(onStartProcessing: {url in
                    document.unprocessedZips.append(url)
                }){ rifff in
                    withAnimation {
                        document.manifest.rifffs.append(rifff)
                        if let index =  document.unprocessedZips.firstIndex(of: rifff.zipURL){
                            document.unprocessedZips.remove(at:index)
                        }
                        try? player.play(set: document, baseURL: baseURL)
                    }
                }
                try! self.player.play(set: document, baseURL: baseURL)
            }
            .onDisappear{
                self.player.stopAndClear()
            }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(rithnnnDocument()), player: Player(), baseURL: URL(string: "")!)
    }
}
