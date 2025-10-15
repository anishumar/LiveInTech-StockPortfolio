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
                
                // Quick Actions
                QuickActionsView()
                    .padding(.vertical, 8)
                
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
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.isPositiveGain ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
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
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Portfolio Content
    
    private var portfolioContent: some View {
        List {
            ForEach(viewModel.portfolioStocks) { stock in
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
            
            // Chart Row
            if !chartPoints.isEmpty {
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
                        isPositive: stock.dailyChange >= 0
                    )
                    .frame(width: 80, height: 30)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Current: \(stock.formattedCurrentPrice)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: stock.dailyChange >= 0 ? "arrow.up" : "arrow.down")
                                .font(.caption2)
                                .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                            
                            Text("\(stock.dailyChange >= 0 ? "+" : "")\(String(format: "%.2f", stock.dailyChange))")
                                .font(.caption)
                                .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                        }
                    }
                }
            } else {
                // Fallback details row without chart
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
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Current: \(stock.formattedCurrentPrice)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: stock.dailyChange >= 0 ? "arrow.up" : "arrow.down")
                                .font(.caption2)
                                .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                            
                            Text("\(stock.dailyChange >= 0 ? "+" : "")\(String(format: "%.2f", stock.dailyChange))")
                                .font(.caption)
                                .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            loadChartData()
        }
    }
    
    private func loadChartData() {
        // Generate mock chart data based on current price and daily change
        let basePrice = stock.currentPrice
        let change = stock.dailyChange
        let volatility = abs(change) * 0.5
        
        chartPoints = (0..<5).map { index in
            let progress = Double(index) / 4.0
            let randomVariation = (Double.random(in: -1...1) * volatility)
            return basePrice - (change * progress) + randomVariation
        }
    }
}

#Preview {
    PortfolioView()
}
