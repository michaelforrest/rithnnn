//
//  ContentView.swift
//  FakeEndlesss
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI

struct ContentView: View {
    let files = [
        "Quantize-Free Zone - michaelforrest - 140BPM - 2021-09-10-20-17",
        "Quantize-Free Zone - fancyspectacles - 140BPM - 2021-09-10-19-37",
        "Timing Accuracy Tests - michaelforrest - 140BPM - 2021-09-11-14-46",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            ForEach(files, id: \.self){ filename in
                Button(action: {
                    share(filename: filename)
                }){
                    Text(filename)
                }
            }
        }
            .padding()
    }
    
    func share(filename: String){
        let url = Bundle.main.url(forResource: filename, withExtension: "zip")!
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
