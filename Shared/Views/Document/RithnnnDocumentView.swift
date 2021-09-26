//
//  RithnnnDocumentView.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI

struct RithnnnDocumentView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var document: RithnnnDocument
    let baseURL: URL
    let player: Player
    
    @State var isDebugging = false
    
    init(document: Binding<RithnnnDocument>, baseURL: URL){
        _document = document
        self.baseURL = baseURL
        self.player = Player(
            document: document.wrappedValue,
            baseURL: baseURL
        )
    }
    
    var body: some View {
        VStack{
            Spacer()
            PlayerView(player: player, debugging: $isDebugging)
            RifffIngestion(document: $document, baseURL: baseURL)
            if isDebugging{
                DocumentDebugView(document: document, player: player)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
//        .navigationBarHidden(true)
        .statusBar(hidden: true)
        
        .overlay(Button(action: { isDebugging.toggle()} ){
            Image(systemName: "ladybug.fill")
                .padding()
                .background(isDebugging ? Color.yellow : Color.clear)
                .cornerRadius(10)
        }, alignment: .bottomTrailing)
        
//        .overlay(Button(action: {
//            presentationMode.wrappedValue.dismiss()
//            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true) // HACKLET
//        }){
//            Image(systemName: "chevron.backward").padding()
//        }, alignment: .topLeading)
    }
}

struct RithnnnDocumentView_Previews: PreviewProvider {
    static var previews: some View {
//        RithnnnDocumentView()
        Text("No")
    }
}
