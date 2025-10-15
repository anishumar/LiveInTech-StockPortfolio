//
//  PortfolioAnalyticsViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class PortfolioAnalyticsViewModel: BaseViewModel {
    // MARK: - Published Properties
    
    @Published var portfolioMetrics: PortfolioMetrics?
    @Published var categoryDistribution: [CategoryDistribution] = []
    @Published var performanceHistory: [PortfolioPerformance] = []
    
    // MARK: - Dependencies
    
    private let portfolioStore = PortfolioStore.shared
    private let networkManager = NetworkManager.shared
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupBindings()
        loadAnalytics()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Listen to portfolio changes
        portfolioStore.$portfolioItems
            .sink { [weak self] _ in
                self?.loadAnalytics()
            }
            .store(in: &cancellables)
        
        // Listen to network updates
        networkManager.$isOnline
            .sink { [weak self] isOnline in
                if isOnline {
                    self?.loadAnalytics()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadAnalytics() {
        isLoading = true
        clearError()
        
        // Load current portfolio data
        let portfolioItems = portfolioStore.portfolioItems
        
        // Calculate metrics
        calculatePortfolioMetrics(portfolioItems: portfolioItems)
        
        // Calculate category distribution
        calculateCategoryDistribution(portfolioItems: portfolioItems)
        
        // Load performance history
        loadPerformanceHistory()
        
        isLoading = false
    }
    
    func refreshAnalytics() {
        loadAnalytics()
    }
    
    override func clearError() {
        super.clearError()
    }
    
    // MARK: - Private Methods
    
    private func calculatePortfolioMetrics(portfolioItems: [PortfolioItem]) {
        let totalInvested = portfolioItems.reduce(0) { total, item in
            total + (item.averagePrice * Double(item.quantity))
        }
        
        let currentValue = portfolioItems.reduce(0) { total, item in
            let currentPrice = Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.price ?? item.averagePrice
            return total + (currentPrice * Double(item.quantity))
        }
        
        let totalGainLoss = currentValue - totalInvested
        let totalGainLossPercentage = totalInvested > 0 ? (totalGainLoss / totalInvested) * 100 : 0
        
        // Calculate ROI (Return on Investment)
        let roi = totalInvested > 0 ? (totalGainLoss / totalInvested) * 100 : 0
        
        // Calculate annualized return (simplified - assuming 1 year)
        let annualizedReturn = roi
        
        // Calculate risk score based on volatility and diversification
        let riskScore = calculateRiskScore(portfolioItems: portfolioItems)
        
        // Calculate diversification score
        let diversificationScore = calculateDiversificationScore(portfolioItems: portfolioItems)
        
        portfolioMetrics = PortfolioMetrics(
            totalInvested: totalInvested,
            currentValue: currentValue,
            totalGainLoss: totalGainLoss,
            totalGainLossPercentage: totalGainLossPercentage,
            roi: roi,
            annualizedReturn: annualizedReturn,
            riskScore: riskScore,
            diversificationScore: diversificationScore
        )
    }
    
    private func calculateCategoryDistribution(portfolioItems: [PortfolioItem]) {
        var categoryTotals: [AssetCategory: (value: Double, count: Int)] = [:]
        let totalValue = portfolioItems.reduce(0) { total, item in
            let currentPrice = Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.price ?? item.averagePrice
            return total + (currentPrice * Double(item.quantity))
        }
        
        for item in portfolioItems {
            // Get stock category from network manager
            if let stock = Stock.mockStocks.first(where: { $0.symbol == item.symbol }) {
                let category = stock.category ?? .other
                let currentPrice = stock.price
                let itemValue = currentPrice * Double(item.quantity)
                
                if let existing = categoryTotals[category] {
                    categoryTotals[category] = (
                        value: existing.value + itemValue,
                        count: existing.count + 1
                    )
                } else {
                    categoryTotals[category] = (value: itemValue, count: 1)
                }
            }
        }
        
        categoryDistribution = categoryTotals.map { category, data in
            CategoryDistribution(
                category: category,
                value: data.value,
                percentage: totalValue > 0 ? (data.value / totalValue) * 100 : 0,
                count: data.count
            )
        }.sorted { $0.value > $1.value }
    }
    
    private func calculateRiskScore(portfolioItems: [PortfolioItem]) -> Double {
        guard !portfolioItems.isEmpty else { return 0 }
        
        // Calculate volatility based on price changes
        let volatilities = portfolioItems.compactMap { item -> Double? in
            if let stock = Stock.mockStocks.first(where: { $0.symbol == item.symbol }) {
                return abs(stock.dailyChangePercentage)
            }
            return nil
        }
        
        let averageVolatility = volatilities.isEmpty ? 0 : volatilities.reduce(0, +) / Double(volatilities.count)
        
        // Calculate concentration risk (higher if portfolio is concentrated in few stocks)
        let concentrationRisk = Double(portfolioItems.count) < 5 ? 8.0 : 4.0
        
        // Combine volatility and concentration for risk score (0-10 scale)
        let riskScore = min(10, (averageVolatility * 2) + concentrationRisk)
        return riskScore
    }
    
    private func calculateDiversificationScore(portfolioItems: [PortfolioItem]) -> Double {
        guard !portfolioItems.isEmpty else { return 0 }
        
        // Count unique categories
        let categories = Set(portfolioItems.compactMap { item in
            Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.category
        })
        
        // Calculate category distribution balance
        let categoryCount = Double(categories.count)
        let maxCategories = Double(AssetCategory.allCases.count)
        
        // Base score from category diversity
        let categoryScore = (categoryCount / maxCategories) * 6
        
        // Bonus for having multiple stocks
        let stockCount = Double(portfolioItems.count)
        let stockScore = min(4, stockCount * 0.5)
        
        return min(10, categoryScore + stockScore)
    }
    
    private func loadPerformanceHistory() {
        // Generate mock performance history for the last 30 days
        let calendar = Calendar.current
        let today = Date()
        var history: [PortfolioPerformance] = []
        
        // Get current metrics
        guard let metrics = portfolioMetrics else { return }
        
        // Generate historical data with some variation
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                // Simulate some variation in portfolio value
                let variation = Double.random(in: -0.05...0.05) // ±5% variation
                let historicalValue = metrics.currentValue * (1 + variation)
                let historicalInvested = metrics.totalInvested * (1 + variation * 0.1) // Less variation in invested amount
                let historicalGainLoss = historicalValue - historicalInvested
                let historicalGainLossPercentage = historicalInvested > 0 ? (historicalGainLoss / historicalInvested) * 100 : 0
                
                history.append(PortfolioPerformance(
                    date: date,
                    value: historicalValue,
                    invested: historicalInvested,
                    gainLoss: historicalGainLoss,
                    gainLossPercentage: historicalGainLossPercentage
                ))
            }
        }
        
        // Sort by date (oldest first)
        performanceHistory = history.sorted { $0.date < $1.date }
    }
    
    // MARK: - Computed Properties
    
    var hasAnalyticsData: Bool {
        return portfolioMetrics != nil && !categoryDistribution.isEmpty
    }
    
    var topPerformingCategory: CategoryDistribution? {
        return categoryDistribution.first
    }
    
    var worstPerformingCategory: CategoryDistribution? {
        return categoryDistribution.last
    }
    
    var portfolioHealthScore: Double {
        guard let metrics = portfolioMetrics else { return 0 }
        
        // Combine multiple factors for health score
        let performanceScore = min(4, max(0, (metrics.totalGainLossPercentage + 20) / 10)) // -20% to +20% range
        let riskScore = max(0, 4 - (metrics.riskScore / 2.5)) // Lower risk is better
        let diversificationScore = metrics.diversificationScore / 2.5 // 0-4 range
        
        return min(10, performanceScore + riskScore + diversificationScore)
    }
    
    var formattedHealthScore: String {
        return String(format: "%.1f/10", portfolioHealthScore)
    }
    
    var healthLevel: String {
        switch portfolioHealthScore {
        case 0..<3: return "Poor"
        case 3..<6: return "Fair"
        case 6..<8: return "Good"
        default: return "Excellent"
        }
    }
}
