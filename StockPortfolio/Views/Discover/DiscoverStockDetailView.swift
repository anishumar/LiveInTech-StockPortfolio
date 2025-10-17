//
//  StockDetailView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct DiscoverStockDetailView: View {
    let stock: Stock
    @Environment(\.dismiss) private var dismiss
    @StateObject private var watchlistViewModel = WatchlistViewModel()
    @State private var showingTradeView = false
    @State private var marketCap: String = ""
    @State private var volume: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Stock Header
                    stockHeader
                    
                    // Price Information
                    priceSection
                    
                    // Stock Chart
                    chartSection
                    
                    // Company Information
                    companySection
                    
                    // Action Buttons
                    actionButtons
                }
                .padding()
            }
            .navigationTitle(stock.symbol)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingTradeView) {
            TradeView()
        }
        .onAppear {
            generateStableMarketData()
        }
    }
    
    // MARK: - Stock Header
    
    private var stockHeader: some View {
        VStack(spacing: 8) {
            Text(stock.name)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(stock.symbol)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Price Section
    
    private var priceSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("$\(stock.price, specifier: "%.2f")")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: stock.dailyChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        
                        Text("\(stock.dailyChange >= 0 ? "+" : "")\(stock.dailyChange, specifier: "%.2f")%")
                            .font(.headline)
                            .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                    }
                    
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Market Cap")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(marketCap)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Volume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(volume)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Chart Section
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Chart")
                .font(.headline)
                .fontWeight(.semibold)
            
            StockChartView(
                chartPoints: stock.chartPoints ?? generateMockChartData(),
                isPositive: stock.dailyChange >= 0
            )
            .frame(height: 120)
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateStableMarketData() {
        // Generate stable values based on stock symbol
        let symbolHash = stock.symbol.hash
        let marketCapValue = 100 + (abs(symbolHash) % 1900)
        let volumeValue = 10 + (abs(symbolHash) % 490)
        
        marketCap = "$\(marketCapValue)B"
        volume = "\(volumeValue)M"
    }
    
    private func generateMockChartData() -> [Double] {
        let basePrice = stock.price
        var points: [Double] = []
        
        for i in 0..<20 {
            let variation = Double.random(in: -0.05...0.05) * basePrice
            let point = basePrice + variation + (Double(i) * 0.1)
            points.append(max(0, point))
        }
        
        return points
    }
    
    // MARK: - Company Section
    
    private var companySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Company Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Sector:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Technology")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if let category = stock.category {
                    HStack {
                        Text("Category:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(category.rawValue.capitalized)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                HStack {
                    Text("Exchange:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("NASDAQ")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Trade Button
            Button(action: {
                showingTradeView = true
            }) {
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Trade")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Watchlist Button
            Button(action: {
                if watchlistViewModel.isInWatchlist(stock) {
                    watchlistViewModel.removeFromWatchlist(stock)
                } else {
                    watchlistViewModel.addToWatchlist(stock)
                }
            }) {
                HStack {
                    Image(systemName: watchlistViewModel.isInWatchlist(stock) ? "eye.fill" : "eye")
                    Text(watchlistViewModel.isInWatchlist(stock) ? "Remove from Watchlist" : "Add to Watchlist")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    DiscoverStockDetailView(stock: Stock.mockStocks.first!)
}
