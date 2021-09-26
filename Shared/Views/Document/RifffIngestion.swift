//
//  RifffIngestion.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI

struct RifffIngestion: View {
    @Binding var document: RithnnnDocument
    var baseURL: URL
    @State var status = ""
    
    var body: some View {
        Text(status).onAppear{
            document.processInboundFiles(onStartProcessing: {url in
                document.unprocessedZips.append(url)
            }){ rifff in
                withAnimation {
                    document.manifest.rifffs.append(rifff)
                    if let index =  document.unprocessedZips.firstIndex(of: rifff.zipURL){
                        document.unprocessedZips.remove(at:index)
                    }
                }
            }
        }
    }
}

struct RifffIngestion_Previews: PreviewProvider {
    static var previews: some View {
        //RifffIngestion()
        Text("Nop")
    }
}
