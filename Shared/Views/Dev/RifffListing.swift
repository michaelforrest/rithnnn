//
//  RifffListing.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI


struct RifffListing: View{
    var rifff: Rifff
    var player: Player
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
                    try? player.replaceRandom(with: loop,rifff: rifff)
                }
            }
        }
        
    }
}
struct RifffListing_Previews: PreviewProvider {
    static var previews: some View {
//        RifffListing()
        Text("Not right now")
    }
}
