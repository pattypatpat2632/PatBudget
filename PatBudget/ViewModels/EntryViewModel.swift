//
//  EntryViewModel.swift
//  PatBudget
//
//  Created by Patrick O'Leary on 3/26/21.
//

import Foundation
import Combine
import FirebaseDatabase
import FirebaseAuth

final class EntryViewModel: ObservableObject {
    @Published var creditAccount = ""
    @Published var debitAccount = ""
    @Published var value = ""
    
    func didEnterTransaction() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let creditValue = Double(value) else {return}
        guard let debitValue = Double(value) else {return}
        
        let transaction = Transaction(debitAccount: debitAccount,
                                      debitValue: debitValue,
                                      creditAccount: creditAccount,
                                      creditValue: creditValue,
                                      date: Date())
        
        DataStore.shared.record(transaction: transaction, in: uid)
    }
}


class DataStore {
    
    static let shared = DataStore()
    private let ref = Database.database().reference()
    
    private init() {}
    
    func createUserInDatabase(_ uid: String, email: String) {
        ref.child("users").child(uid).child("email").setValue(email)
    }
    
    func record(transaction: Transaction, in uid: String) {
        ref.child("users").child(uid).child("transactions").childByAutoId().setValue([
            "debitAccount": transaction.debitAccount,
            "debitValue": transaction.debitValue,
            "creditAccount": transaction.creditAccount,
            "creditValue": transaction.creditValue,
            "date": transaction.date.timeIntervalSince1970
        ])
    }
}

struct Transaction {
    let debitAccount: String
    let debitValue: Double
    let creditAccount: String
    let creditValue: Double
    let date: Date
}
