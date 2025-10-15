//
//  NetworkTestView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI
import Combine

struct NetworkTestView: View {
    @StateObject private var networkManager = NetworkManager.shared
    @State private var stocks: [Stock] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchQuery = ""
    @State private var searchResults: [Stock] = []
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Network Status
                HStack {
                    Circle()
                        .fill(networkManager.isOnline ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    
                    Text(networkManager.isOnline ? "Online" : "Offline")
                        .font(.caption)
                        .foregroundColor(networkManager.isOnline ? .green : .red)
                    
                    Spacer()
                    
                    if let error = networkManager.lastError {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                // Test Controls
                VStack(spacing: 12) {
                    Button("Fetch All Stocks") {
                        fetchAllStocks()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                    
                    Button("Simulate Network Failure") {
                        networkManager.simulateNetworkFailure()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    
                    Button("Simulate Timeout") {
                        networkManager.simulateTimeout()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.orange)
                    
                    Button("Reset Network") {
                        networkManager.resetNetwork()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.green)
                }
                .padding(.horizontal)
                
                // Search
                VStack(alignment: .leading, spacing: 8) {
                    Text("Search Stocks")
                        .font(.headline)
                    
                    TextField("Enter symbol or name", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: searchQuery) { query in
                            if !query.isEmpty {
                                searchStocks(query: query)
                            } else {
                                searchResults = []
                            }
                        }
                }
                .padding(.horizontal)
                
                // Results
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        Text("Error")
                            .font(.headline)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        if !searchResults.isEmpty {
                            Section("Search Results") {
                                ForEach(searchResults) { stock in
                                    StockRowView(stock: stock)
                                }
                            }
                        } else {
                            Section("All Stocks") {
                                ForEach(stocks) { stock in
                                    StockRowView(stock: stock)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Network Test")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func fetchAllStocks() {
        isLoading = true
        errorMessage = nil
        
        networkManager.fetchAllStocks()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { stocks in
                    self.stocks = stocks
                    print("✅ Fetched \(stocks.count) stocks")
                }
            )
            .store(in: &cancellables)
    }
    
    private func searchStocks(query: String) {
        networkManager.searchStocks(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Search failed: \(error)")
                    }
                },
                receiveValue: { results in
                    searchResults = results
                    print("🔍 Found \(results.count) results for '\(query)'")
                }
            )
            .store(in: &cancellables)
    }
}

struct StockRowView: View {
    let stock: Stock
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(stock.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(stock.formattedPrice)
                    .font(.headline)
                    .fontWeight(.semibold)
                
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
        .padding(.vertical, 4)
    }
}

#Preview {
    NetworkTestView()
}
