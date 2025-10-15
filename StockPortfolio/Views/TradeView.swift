//
//  TradeView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct TradeView: View {
    @StateObject private var viewModel = TradeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Trade Type Selector
                tradeTypeSelector
                
                // Search Section
                searchSection
                
                // Stock Selection
                if viewModel.hasSelectedStock {
                    stockDetailsSection
                } else {
                    searchResultsSection
                }
                
                Spacer()
            }
            .navigationTitle("Trade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.hasSelectedStock {
                        Button("Clear") {
                            viewModel.clearSelection()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Trade Type Selector
    
    private var tradeTypeSelector: some View {
        Picker("Trade Type", selection: $viewModel.tradeType) {
            ForEach(TradeType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    // MARK: - Search Section
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search stocks by symbol or name", text: $viewModel.searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            if !viewModel.searchQuery.isEmpty && viewModel.searchResults.isEmpty && !viewModel.isLoading {
                Text("No stocks found")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Search Results Section
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !viewModel.searchResults.isEmpty {
                Text("Search Results")
                    .font(.headline)
                    .padding(.horizontal)
                
                List(viewModel.searchResults) { stock in
                    StockSearchRowView(stock: stock) {
                        viewModel.selectStock(stock)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 300)
            }
        }
    }
    
    // MARK: - Stock Details Section
    
    private var stockDetailsSection: some View {
        VStack(spacing: 20) {
            // Selected Stock Info
            if let stock = viewModel.selectedStock {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stock.symbol)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(stock.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(viewModel.formattedCurrentPrice)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 4) {
                                Image(systemName: stock.dailyChange >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.caption)
                                    .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                                
                                Text(stock.formattedChange)
                                    .font(.caption)
                                    .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Available Quantity (for sell)
                    if viewModel.tradeType == .sell {
                        Text(viewModel.formattedAvailableQuantity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Quantity Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Quantity")
                    .font(.headline)
                
                HStack {
                    TextField("Enter quantity", text: $viewModel.quantity)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Max") {
                        if viewModel.tradeType == .sell {
                            viewModel.quantity = "\(viewModel.availableQuantity)"
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.tradeType == .buy)
                }
            }
            
            // Total Cost
            if !viewModel.quantity.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Cost")
                        .font(.headline)
                    
                    Text(viewModel.formattedTotalCost)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            // Trade Button
            Button(action: {
                viewModel.executeTrade()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text(viewModel.tradeButtonTitle)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canExecuteTrade ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(!viewModel.canExecuteTrade || viewModel.isLoading)
        }
        .padding()
    }
}

// MARK: - Stock Search Row View

struct StockSearchRowView: View {
    let stock: Stock
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.symbol)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(stock.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(stock.formattedPrice)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Text(stock.formattedChange)
                            .font(.caption)
                            .foregroundColor(stock.isPositiveChange ? .green : .red)
                        
                        Text(stock.formattedChangePercentage)
                            .font(.caption)
                            .foregroundColor(stock.isPositiveChange ? .green : .red)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TradeView()
}
