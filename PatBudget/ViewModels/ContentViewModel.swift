//
//  ContentViewModel.swift
//  PatBudget
//
//  Created by Patrick O'Leary on 3/26/21.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth

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
    
    func logInUser() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
        }
    }
}
