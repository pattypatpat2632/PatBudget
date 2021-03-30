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
    @Published var previousTransactions = [RecordedTransaction]()
    private var filteredAccounts: Set<String> {
        var set = Set<String>()
        previousTransactions.forEach { transaction in
            if !set.contains(transaction.creditAccount) {
                set.insert(transaction.creditAccount)
            }
            if !set.contains(transaction.debitAccount) {
                set.insert(transaction.debitAccount)
            }
        }
        return set
    }
    
    var creditAccountOptions: [String] {
        return search(set: filteredAccounts, forText: creditAccount)
    }
    
    var debitAccountOptions: [String] {
        return search(set: filteredAccounts, forText: debitAccount)
    }
    
    private var bag = Set<AnyCancellable>()
    
    func didEnterTransaction() {
        guard creditAccount != debitAccount else {return}
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
    
    func viewDidAppear() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        DataStore.shared.observeTransactions(in: uid).sink { (_) in
            
        } receiveValue: { (transactions) in
            self.previousTransactions = transactions
        }.store(in: &bag)
    }
    
    func search(set: Set<String>, forText text: String) -> [String] {
        let strippedText = text.trimmingCharacters(in: .whitespaces)
        guard !strippedText.isEmpty else {return []}
        
        let matcher = SearchMatcher(searchString: strippedText)
        
        let searchedSet = set.filter { accountName in
            return matcher.matches(accountName)
        }
        
        return Array(searchedSet)
    }
    
    struct SearchMatcher {
        
        private(set) var searchTokens: [String.SubSequence]
        
        init(searchString: String) {
            self.searchTokens = searchString
                .split(whereSeparator: {$0.isWhitespace})
                .sorted{ $0.count <= $1.count }
        }
        
        func matches(_ candidateString: String) -> Bool {
            guard !searchTokens.isEmpty else { return true }
            var candidateStringTokens = candidateString.split(whereSeparator: { $0.isWhitespace })
            
            for searchToken in searchTokens {
                var matchedSearchToken = false
                
                for (candidateStringTokenIndex, candidateStringToken) in candidateStringTokens.enumerated() {
                    if let range = candidateStringToken.range(of: searchToken, options: [.caseInsensitive, .diacriticInsensitive]),
                       range.lowerBound == candidateStringToken.startIndex {
                        matchedSearchToken = true
                        
                        candidateStringTokens.remove(at: candidateStringTokenIndex)
                        break
                    }
                }
                guard matchedSearchToken else { return false }
            }
            return true
        }
    }
}


class DataStore {
    
    static let shared = DataStore()
    private let ref = Database.database().reference()
    
    private init() {}
    
    func createUserInDatabase(_ uid: String, email: String) {
        ref.child("users").child(uid).child("email").setValue(email)
    }
    
    func observeTransactions(in uid: String) -> AnyPublisher<[RecordedTransaction], Error> {
        let subject = PassthroughSubject<[RecordedTransaction], Error>()
        ref.child("users").child(uid).child("transactions").observe(.value) { (snapshot) in
            var transactions = [RecordedTransaction]()
            let dict = snapshot.value as? [String: Any] ?? [:]
            dict.keys.forEach { key in
                let subDict = dict[key] as? [String: Any] ?? [:]
                if let transaction = RecordedTransaction(id: key, subDict) {
                    transactions.append(transaction)
                }
            }
            subject.send(transactions)
        }
        return subject.eraseToAnyPublisher()
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

protocol Entry {
    var debitAccount: String {get}
    var debitValue: Double {get}
    var creditAccount: String {get}
    var creditValue: Double {get}
    var date: Date {get}
}

struct Transaction: Entry {
    var debitAccount: String
    var debitValue: Double
    var creditAccount: String
    var creditValue: Double
    var date: Date
}

struct RecordedTransaction: Entry, Identifiable {
    var id: String
    var debitAccount: String
    var debitValue: Double
    var creditAccount: String
    var creditValue: Double
    var date: Date
}

extension RecordedTransaction {
    init?(id: String, _ dict: [String: Any]) {
        self.id = id
        guard let debitAccount = dict["debitAccount"] as? String else {return nil}
        guard let debitValue = dict["debitValue"] as? Double else {return nil}
        guard let creditAccount = dict["creditAccount"] as? String else {return nil}
        guard let creditValue = dict["creditValue"] as? Double else {return nil}
        guard let date = dict["date"] as? TimeInterval else {return nil}
        
        self.debitAccount = debitAccount
        self.debitValue = debitValue
        self.creditAccount = creditAccount
        self.creditValue = creditValue
        self.date = Date(timeIntervalSince1970: date)
    }
}
