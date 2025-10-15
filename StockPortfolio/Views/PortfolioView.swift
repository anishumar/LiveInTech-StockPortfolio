//
//  PortfolioView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct PortfolioView: View {
    @StateObject private var viewModel = PortfolioViewModel()
    @State private var showingTradeView = false
    @State private var showingErrorAlert = false
    @State private var errorToShow: Error?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Offline Indicator
                OfflineIndicatorView()
                
                // Portfolio Summary Header
                portfolioSummaryHeader
                
                // Portfolio Content
                if viewModel.hasPortfolioItems {
                    portfolioContent
                } else {
                    emptyPortfolioView
                }
            }
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Trade") {
                        showingTradeView = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .refreshable {
                viewModel.refreshPortfolio()
            }
            .sheet(isPresented: $showingTradeView) {
                TradeView()
            }
            .onChange(of: viewModel.errorMessage) { errorMessage in
                if let errorMessage = errorMessage {
                    errorToShow = NSError(domain: "PortfolioError", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    showingErrorAlert = true
                }
            }
            .overlay {
                if showingErrorAlert, let error = errorToShow {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showingErrorAlert = false
                            }
                        
                        ErrorAlertView(
                            error: error,
                            onRetry: {
                                viewModel.refreshPortfolio()
                            },
                            onDismiss: {
                                showingErrorAlert = false
                                viewModel.clearError()
                            }
                        )
                        .padding()
                    }
                }
            }
        }
    }
    
    // MARK: - Portfolio Summary Header
    
    private var portfolioSummaryHeader: some View {
        VStack(spacing: 16) {
            // Total Value
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                    Text("Total Portfolio Value")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(viewModel.formattedTotalValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Gain/Loss
            if viewModel.hasPortfolioItems {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isPositiveGain ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                        .foregroundColor(viewModel.isPositiveGain ? .green : .red)
                    
                    Text(viewModel.formattedTotalGainLoss)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.isPositiveGain ? .green : .red)
                    
                    Text(viewModel.formattedTotalGainLossPercentage)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.isPositiveGain ? .green : .red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            // Refresh Status
            if viewModel.isRefreshing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Updating prices...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: viewModel.totalPortfolioValue)
    }
    
    // MARK: - Portfolio Content
    
    private var portfolioContent: some View {
        List {
            ForEach(viewModel.portfolioStocks, id: \.symbol) { stock in
                NavigationLink(destination: TradeView()) {
                    PortfolioStockRowView(stock: stock)
                }
                .buttonStyle(PlainButtonStyle())
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Sell") {
                        // Quick sell action
                        showingTradeView = true
                    }
                    .tint(.red)
                    
                    Button("Trade") {
                        showingTradeView = true
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button("Buy More") {
                        // Quick buy action
                        showingTradeView = true
                    }
                    .tint(.green)
                }
            }
        }
        .listStyle(PlainListStyle())
        .animation(.easeInOut(duration: 0.3), value: viewModel.portfolioStocks.count)
    }
    
    // MARK: - Empty Portfolio View
    
    private var emptyPortfolioView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Stocks in Portfolio")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Start building your portfolio by buying your first stock.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button("Start Trading") {
                showingTradeView = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Portfolio Stock Row View

struct PortfolioStockRowView: View {
    let stock: PortfolioStock
    @State private var chartPoints: [Double] = []
    
    // Pre-computed values for performance
    
    private var isPositiveChange: Bool {
        stock.dailyChange >= 0
    }
    
    private var changeIcon: String {
        isPositiveChange ? "arrow.up" : "arrow.down"
    }
    
    private var changeColor: Color {
        isPositiveChange ? .green : .red
    }
    
    private var formattedDailyChange: String {
        let sign = isPositiveChange ? "+" : ""
        return "\(sign)\(String(format: "%.2f", stock.dailyChange))"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header Row
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
                    Text(stock.formattedTotalValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        Text(stock.formattedGainLoss)
                            .font(.caption)
                            .foregroundColor(stock.isPositiveGain ? .green : .red)
                        
                        Text(stock.formattedGainLossPercentage)
                            .font(.caption)
                            .foregroundColor(stock.isPositiveGain ? .green : .red)
                    }
                }
            }
            
            // Details Row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(stock.quantity) shares")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Avg: \(String(format: "$%.2f", stock.averagePrice))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Mini Chart
                StockChartView(
                    chartPoints: chartPoints,
                    isPositive: isPositiveChange
                )
                .frame(width: 80, height: 30)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Current: \(stock.formattedCurrentPrice)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: changeIcon)
                            .font(.caption2)
                            .foregroundColor(changeColor)
                        
                        Text(formattedDailyChange)
                            .font(.caption)
                            .foregroundColor(changeColor)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            generateStableChartData()
        }
    }
    
    private func generateStableChartData() {
        // Generate stable chart data based on stock symbol and current price
        // This ensures the same chart is shown for the same stock
        let basePrice = stock.currentPrice
        let change = stock.dailyChange
        let volatility = abs(change) * 0.3
        
        // Use stock symbol as seed for consistent random generation
        let seed = stock.symbol.hashValue
        var generator = SeededRandomNumberGenerator(seed: UInt64(abs(seed)))
        
        chartPoints = (0..<5).map { index in
            let progress = Double(index) / 4.0
            let randomVariation = (Double.random(in: -1...1, using: &generator) * volatility)
            return basePrice - (change * progress) + randomVariation
        }
    }
}

// MARK: - Seeded Random Number Generator

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}

#Preview {
    PortfolioView()
}
