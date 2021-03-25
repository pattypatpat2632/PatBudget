//
//  ContentView.swift
//  PatBudget
//
//  Created by Patrick O'Leary on 3/24/21.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    
    @ObservedObject var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoggedIn {
                Text("hey you're logged in! fucking rad shit dude")
            } else {
                TextField("Email", text: $viewModel.email,
                          onEditingChanged: {_ in},
                          onCommit: viewModel.createUser)
                TextField("Password", text: $viewModel.password,
                          onEditingChanged: {_ in},
                          onCommit: viewModel.createUser)
            }
        }
        .onAppear(perform: viewModel.viewDidAppear)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ContentViewModel: ObservableObject, Identifiable {
    @Published var isLoggedIn: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    var authHandle: AuthStateDidChangeListenerHandle?
    
    func viewDidAppear() {
        FirebaseApp.configure()
        authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print(user.uid)
                self.isLoggedIn = true
            }
        }
    }
    
    func createUser() {
        print("Should create user. Email: \(email) Password: \(password)")
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
        }
    }
    
    func logInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
        }
    }
}


