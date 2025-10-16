//
//  DiscoverView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var showingWatchlist = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                searchHeader
                
                // Content
                if viewModel.filteredStocks.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingWatchlist = true
                    }) {
                        Image(systemName: "eye")
                    }
                }
            }
        }
        .sheet(isPresented: $showingWatchlist) {
            WatchlistView()
        }
        .onAppear {
            viewModel.loadAllStocks()
        }
    }
    
    // MARK: - Search Header
    
    private var searchHeader: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search stocks, ETFs, or symbols...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Content View
    
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredStocks) { stock in
                    StockRowView(stock: stock)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No stocks found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search or check back later")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Stock Row View

struct StockRowView: View {
    let stock: Stock
    
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
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(stock.price, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    Image(systemName: stock.dailyChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)
                    
                    Text("\(stock.dailyChange >= 0 ? "+" : "")\(stock.dailyChange, specifier: "%.2f")%")
                        .font(.subheadline)
                        .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    DiscoverView()
}