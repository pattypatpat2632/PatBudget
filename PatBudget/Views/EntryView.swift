//
//  EntryView.swift
//  PatBudget
//
//  Created by Patrick O'Leary on 3/26/21.
//

import SwiftUI

struct EntryView: View {
    
    @ObservedObject var viewModel = EntryViewModel()
    @State private var isEditingCreditAccount = false
    @State private var isEditingDebitAccount = false
    
    var body: some View {
        VStack {
            TextField("Credit", text: $viewModel.creditAccount) { (didStartEditing) in
                if didStartEditing { isEditingCreditAccount = true }
            } onCommit: {
                isEditingCreditAccount = false
            }
            
            if isEditingCreditAccount {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.creditAccountOptions, id: \.self) { account in
                            Button(account) {
                                viewModel.creditAccount = account
                                isEditingCreditAccount = false
                            }
                            
                        }
                    }
                }
            }
            
            TextField("Credit Amount", text: $viewModel.value)
                .keyboardType(.decimalPad)
            
            TextField("Debit", text: $viewModel.debitAccount) { (didStartEditing) in
                if didStartEditing { isEditingDebitAccount = true }
            } onCommit: {
                isEditingDebitAccount = false
            }
            
            if isEditingDebitAccount {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.debitAccountOptions, id: \.self) { account in
                            Button(account) {
                                viewModel.debitAccount = account
                                isEditingDebitAccount = false
                            }
                        }
                    }
                }
            }
            
            TextField("Debit Amount", text: $viewModel.value)
                .keyboardType(.decimalPad)
            
            Button("Enter", action: viewModel.didEnterTransaction)
            Text("Total transactions: \(viewModel.previousTransactions.count)")
        }.onAppear(perform: viewModel.viewDidAppear)
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView()
    }
}

struct Account: Identifiable, Hashable {
    let name: String
    var id: String {
        return name
    }
}
