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
    @State var isCreateUserDisplayed = false
    
    var body: some View {
        VStack {
            if viewModel.isLoggedIn {
                Text("hey you're logged in! fucking rad shit dude")
            } else {
                Text("Log In")
                TextField("Email",
                          text: $viewModel.email,
                          onEditingChanged: {_ in},
                          onCommit: viewModel.logInUser)
                SecureField("Password",
                            text: $viewModel.password,
                            onCommit: viewModel.logInUser)
                Button("New User") {
                    isCreateUserDisplayed.toggle()
                }
                
            }
        }
        .sheet(isPresented: $isCreateUserDisplayed) {
            VStack {
                Text("Create User")
                TextField("Email", text: $viewModel.email,
                          onEditingChanged: {_ in},
                          onCommit: viewModel.createUser)
                    .keyboardType(.emailAddress)
                SecureField("Password",
                            text: $viewModel.password,
                            onCommit: {
                                viewModel.createUser()
                                isCreateUserDisplayed = false
                            })
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




