//
//  TransactionHistoryView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct TransactionHistoryView: View {
    @StateObject private var portfolioStore = PortfolioStore.shared
    @State private var selectedFilter: TransactionFilter = .all
    
    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case buy = "Buy"
        case sell = "Sell"
    }
    
    private var filteredTransactions: [Transaction] {
        let transactions = portfolioStore.transactions.sorted { $0.timestamp > $1.timestamp }
        
        switch selectedFilter {
        case .all:
            return transactions
        case .buy:
            return transactions.filter { $0.type == .buy }
        case .sell:
            return transactions.filter { $0.type == .sell }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TransactionFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Transaction List
                if filteredTransactions.isEmpty {
                    emptyStateView
                } else {
                    List(filteredTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Transaction History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Transactions")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Your buy and sell transactions will appear here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: transaction.timestamp)
    }
    
    private var transactionIcon: String {
        switch transaction.type {
        case .buy:
            return "arrow.down.circle.fill"
        case .sell:
            return "arrow.up.circle.fill"
        }
    }
    
    private var transactionColor: Color {
        switch transaction.type {
        case .buy:
            return .green
        case .sell:
            return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Transaction Icon
            Image(systemName: transactionIcon)
                .font(.title2)
                .foregroundColor(transactionColor)
                .frame(width: 30)
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.symbol)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(transaction.formattedTotalValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(transactionColor)
                }
                
                HStack {
                    Text("\(transaction.type.rawValue) \(transaction.quantity) shares")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("@ \(String(format: "$%.2f", transaction.price))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TransactionHistoryView()
}
