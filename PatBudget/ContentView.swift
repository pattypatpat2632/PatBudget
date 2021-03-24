//
//  ContentView.swift
//  PatBudget
//
//  Created by Patrick O'Leary on 3/24/21.
//

import SwiftUI
import Firebase

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear(perform: FirebaseApp.configure)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
