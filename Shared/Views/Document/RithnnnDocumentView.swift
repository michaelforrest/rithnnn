//
//  RithnnnDocumentView.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI

struct RithnnnDocumentView: View {
    @Binding var document: RithnnnDocument
    let baseURL: URL
    let player: Player
    
    init(document: Binding<RithnnnDocument>, baseURL: URL){
        _document = document
        self.baseURL = baseURL
        self.player = Player(
            document: document.wrappedValue,
            baseURL: baseURL
        )
    }
    
    var body: some View {
        PlayerView(player: player)
        RifffIngestion(document: $document, baseURL: baseURL)
        DocumentDebugView(document: document, player: player)
    }
}

struct RithnnnDocumentView_Previews: PreviewProvider {
    static var previews: some View {
//        RithnnnDocumentView()
        Text("No")
    }
}
