//
//  ContentView.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI

struct DebugMasterView: View {
    @Binding var document: RithnnnDocument
    @ObservedObject var player: Player
    var baseURL: URL
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    // FIXME: change to display link instead of 1/60
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    @State var playerDebugging = ""
    @State var meterLevel: CGFloat = 0
    @State var barPosition: TimeInterval = 0
    
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
                .frame(maxWidth: .infinity)
                .frame(height: 2)
                .scaleEffect(x: CGFloat(barPosition), y: 1, anchor: .leading)
                
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
                self.playerDebugging = player.debugString
                self.meterLevel = CGFloat(player.outputMeterLevel)
                self.barPosition = player.barPosition
                player.updateSlotPositions()
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
        DebugMasterView(document: .constant(RithnnnDocument()), player: Player(), baseURL: URL(string: "")!)
    }
}
