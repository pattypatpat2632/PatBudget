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
                print("User is logged in. UID: \(user.uid)")
                self.isLoggedIn = true
            }
        }
    }
    
    func createUser() {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard let result = result, let email = result.user.email else {return}
            DataStore.shared.createUserInDatabase(result.user.uid, email: email)
        }
    }
    
    func logInUser() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
        }
    }
}
