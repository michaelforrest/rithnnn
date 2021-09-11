//
//  ContentView.swift
//  Shared
//
//  Created by Michael Forrest on 11/09/2021.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: rithnnnDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(rithnnnDocument()))
    }
}
