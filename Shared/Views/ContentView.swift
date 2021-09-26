//
//  ContentView.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI

extension CGRect{
    var center: CGPoint{
        CGPoint(x: width / 2, y: height / 2)
    }
    var radius: CGFloat{
        width / 2
    }
}

struct ProgressCircle: Shape{
    var progress: Double
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: rect.center,
            radius: rect.radius,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: (360 * progress) - 90),
            clockwise: false
        )
        return p.strokedPath(.init(lineWidth: 3, lineCap: .round, dash: progress < 0 ? [3, 5] : [1], dashPhase: 0))
    }
}

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
        ContentView(document: .constant(rithnnnDocument()), player: Player(), baseURL: URL(string: "")!)
    }
}
