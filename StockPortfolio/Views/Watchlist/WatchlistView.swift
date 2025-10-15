//
//  WatchlistView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct WatchlistView: View {
    @StateObject private var viewModel = WatchlistViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.watchlistStocks.isEmpty {
                    emptyStateView
                } else {
                    watchlistContent
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingAddStock = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddStock) {
                AddToWatchlistView { stock in
                    viewModel.addToWatchlist(stock)
                }
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "eye.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Stocks in Watchlist")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add stocks to your watchlist to track their performance without owning them.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Add Stocks") {
                viewModel.showingAddStock = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Watchlist Content
    
    private var watchlistContent: some View {
        VStack(spacing: 0) {
            // Watchlist Summary
            watchlistSummary
            
            // Watchlist List
            watchlistList
        }
    }
    
    private var watchlistSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Watchlist Summary")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.watchlistStocks.count) stocks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                SummaryMetric(
                    title: "Total Value",
                    value: viewModel.totalWatchlistValue,
                    color: Color.blue
                )
                
                SummaryMetric(
                    title: "Avg Change",
                    value: viewModel.averageChange,
                    color: viewModel.averageChangeColor
                )
                
                SummaryMetric(
                    title: "Gainers",
                    value: "\(viewModel.gainersCount)",
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
    
    private var watchlistList: some View {
        List {
            ForEach(viewModel.watchlistStocks) { stock in
                WatchlistStockRowView(stock: stock) {
                    viewModel.removeFromWatchlist(stock)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Remove", role: .destructive) {
                        viewModel.removeFromWatchlist(stock)
                    }
                    
                    Button("Trade") {
                        // Navigate to trade view
                    }
                    .tint(Color.blue)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct SummaryMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WatchlistStockRowView: View {
    let stock: Stock
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Stock Info
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", stock.price))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    Image(systemName: stock.dailyChange >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                        .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                    
                    Text(String(format: "%.2f", abs(stock.dailyChange)))
                        .font(.subheadline)
                        .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddToWatchlistView: View {
    @StateObject private var viewModel = AdvancedSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    let onAdd: (Stock) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.filteredStocks.isEmpty {
                    Text("No stocks available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.filteredStocks) { stock in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(stock.symbol)
                                    .font(.headline)
                                Text(stock.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Add") {
                                onAdd(stock)
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("Add to Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadAllStocks()
        }
    }
}

#Preview {
    WatchlistView()
}
