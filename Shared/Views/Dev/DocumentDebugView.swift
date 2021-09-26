//
//  ContentView.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI

struct DocumentDebugView: View {
    var document: RithnnnDocument
    var player: Player

    var body: some View {
        VStack {
            ForEach(document.unprocessedZips, id: \.self){ url in
                HStack{
                    Image(systemName: "doc.zipper")
                    Text(url.lastPathComponent)
                    Spacer()
                    ProgressView()
                }
            }
            ForEach(document.manifest.rifffs){ rifff in
                RifffListing(rifff: rifff, player: player)
            }
            TextField("UUID", text: Binding.constant(document.manifest.uuid.uuidString))
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("URHH")
    }
}
