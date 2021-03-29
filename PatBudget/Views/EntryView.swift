//
//  EntryView.swift
//  PatBudget
//
//  Created by Patrick O'Leary on 3/26/21.
//

import SwiftUI

struct EntryView: View {
    
    @ObservedObject var viewModel = EntryViewModel()
    
    
    var body: some View {
        VStack {
            TextField("Credit", text: $viewModel.creditAccount)
            TextField("Credit Amount", text: $viewModel.value)
                .keyboardType(.decimalPad)
            TextField("Debit", text: $viewModel.debitAccount)
            TextField("Debit Amount", text: $viewModel.value)
                .keyboardType(.decimalPad)
            Button("Enter", action: viewModel.didEnterTransaction)
        }
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
