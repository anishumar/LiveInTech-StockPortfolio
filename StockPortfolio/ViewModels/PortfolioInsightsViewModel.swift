//
//  PortfolioInsightsViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class PortfolioInsightsViewModel: BaseViewModel {
    // MARK: - Published Properties
    
    @Published var insights: [PortfolioInsight] = []
    @Published var isGenerating = false
    
    // MARK: - Dependencies
    
    private let portfolioStore = PortfolioStore.shared
    private let userDefaults = UserDefaults.standard
    private let insightsKey = "portfolioInsights"
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        loadInsights()
    }
    
    // MARK: - Public Methods
    
    func generateInsights() {
        isGenerating = true
        clearError()
        
        // Simulate AI processing time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.createInsights()
            self.isGenerating = false
        }
    }
    
    func markAsRead(_ insight: PortfolioInsight) {
        if let index = insights.firstIndex(where: { $0.id == insight.id }) {
            // In a real app, you'd update the isRead property
            // For now, we'll just remove it from the list
            insights.remove(at: index)
            saveInsights()
        }
    }
    
    func dismissInsight(_ insight: PortfolioInsight) {
        insights.removeAll { $0.id == insight.id }
        saveInsights()
    }
    
    func clearAllInsights() {
        insights.removeAll()
        saveInsights()
    }
    
    // MARK: - Private Methods
    
    private func loadInsights() {
        if let data = userDefaults.data(forKey: insightsKey),
           let savedInsights = try? JSONDecoder().decode([PortfolioInsight].self, from: data) {
            insights = savedInsights
        } else {
            // Load mock insights for demo
            insights = PortfolioInsight.mockInsights
        }
    }
    
    private func saveInsights() {
        if let data = try? JSONEncoder().encode(insights) {
            userDefaults.set(data, forKey: insightsKey)
        }
    }
    
    private func createInsights() {
        let portfolioItems = portfolioStore.portfolioItems
        var newInsights: [PortfolioInsight] = []
        
        // Analyze portfolio for insights
        newInsights.append(contentsOf: analyzeDiversification(portfolioItems))
        newInsights.append(contentsOf: analyzeConcentration(portfolioItems))
        newInsights.append(contentsOf: analyzePerformance(portfolioItems))
        newInsights.append(contentsOf: analyzeRisk(portfolioItems))
        newInsights.append(contentsOf: analyzeOpportunities(portfolioItems))
        
        // Add new insights to existing ones
        insights.append(contentsOf: newInsights)
        
        // Sort by priority and date
        insights.sort { insight1, insight2 in
            if insight1.priority.rawValue != insight2.priority.rawValue {
                return insight1.priority.rawValue > insight2.priority.rawValue
            }
            return insight1.createdDate > insight2.createdDate
        }
        
        saveInsights()
    }
    
    private func analyzeDiversification(_ portfolioItems: [PortfolioItem]) -> [PortfolioInsight] {
        var insights: [PortfolioInsight] = []
        
        // Check if portfolio is too concentrated in one sector
        let totalValue = portfolioItems.reduce(0) { total, item in
            let currentPrice = Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.price ?? item.averagePrice
            return total + (currentPrice * Double(item.quantity))
        }
        
        if totalValue > 0 {
            let equityStocks = portfolioItems.filter { item in
                if let stock = Stock.mockStocks.first(where: { $0.symbol == item.symbol }) {
                    return stock.category == .equity
                }
                return false
            }
            
            let equityValue = equityStocks.reduce(0) { total, item in
                let currentPrice = Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.price ?? item.averagePrice
                return total + (currentPrice * Double(item.quantity))
            }
            
            let equityPercentage = (equityValue / totalValue) * 100
            
            if equityPercentage > 80 {
                insights.append(PortfolioInsight(
                    type: .recommendation,
                    priority: .medium,
                    title: "Diversification Opportunity",
                    description: "Your portfolio is \(String(format: "%.1f", equityPercentage))% invested in equity stocks. Consider diversifying into other asset classes.",
                    recommendation: "Add bonds, REITs, or commodities to balance your portfolio and reduce risk.",
                    relatedStocks: equityStocks.map { $0.symbol }
                ))
            }
        }
        
        return insights
    }
    
    private func analyzeConcentration(_ portfolioItems: [PortfolioItem]) -> [PortfolioInsight] {
        var insights: [PortfolioInsight] = []
        
        if portfolioItems.count < 5 {
            insights.append(PortfolioInsight(
                type: .risk,
                priority: .high,
                title: "Low Diversification",
                description: "Your portfolio contains only \(portfolioItems.count) stocks. This creates concentration risk.",
                recommendation: "Consider adding more stocks from different sectors to improve diversification.",
                relatedStocks: portfolioItems.map { $0.symbol }
            ))
        }
        
        // Check for single stock concentration
        let totalValue = portfolioItems.reduce(0) { total, item in
            let currentPrice = Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.price ?? item.averagePrice
            return total + (currentPrice * Double(item.quantity))
        }
        
        if totalValue > 0 {
            for item in portfolioItems {
                let currentPrice = Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.price ?? item.averagePrice
                let itemValue = currentPrice * Double(item.quantity)
                let percentage = (itemValue / totalValue) * 100
                
                if percentage > 30 {
                    insights.append(PortfolioInsight(
                        type: .warning,
                        priority: .high,
                        title: "High Concentration Risk",
                        description: "\(item.symbol) represents \(String(format: "%.1f", percentage))% of your portfolio. This creates significant concentration risk.",
                        recommendation: "Consider reducing your position in \(item.symbol) and diversifying into other stocks.",
                        relatedStocks: [item.symbol]
                    ))
                }
            }
        }
        
        return insights
    }
    
    private func analyzePerformance(_ portfolioItems: [PortfolioItem]) -> [PortfolioInsight] {
        var insights: [PortfolioInsight] = []
        
        // Simulate performance analysis
        let totalInvested = portfolioItems.reduce(0) { total, item in
            total + (item.averagePrice * Double(item.quantity))
        }
        
        let currentValue = portfolioItems.reduce(0) { total, item in
            let currentPrice = Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.price ?? item.averagePrice
            return total + (currentPrice * Double(item.quantity))
        }
        
        if totalInvested > 0 {
            let gainLoss = currentValue - totalInvested
            let gainLossPercentage = (gainLoss / totalInvested) * 100
            
            if gainLossPercentage > 10 {
                insights.append(PortfolioInsight(
                    type: .performance,
                    priority: .low,
                    title: "Strong Performance",
                    description: "Your portfolio has gained \(String(format: "%.1f", gainLossPercentage))% since purchase. Excellent work!",
                    recommendation: "Consider taking some profits and rebalancing your portfolio.",
                    relatedStocks: portfolioItems.map { $0.symbol }
                ))
            } else if gainLossPercentage < -10 {
                insights.append(PortfolioInsight(
                    type: .warning,
                    priority: .medium,
                    title: "Portfolio Underperformance",
                    description: "Your portfolio has declined \(String(format: "%.1f", abs(gainLossPercentage)))% since purchase. Review your holdings.",
                    recommendation: "Consider reviewing your investment strategy and potentially rebalancing your portfolio.",
                    relatedStocks: portfolioItems.map { $0.symbol }
                ))
            }
        }
        
        return insights
    }
    
    private func analyzeRisk(_ portfolioItems: [PortfolioItem]) -> [PortfolioInsight] {
        var insights: [PortfolioInsight] = []
        
        // Check for high volatility stocks
        let highVolatilityStocks = portfolioItems.filter { item in
            if let stock = Stock.mockStocks.first(where: { $0.symbol == item.symbol }) {
                return abs(stock.dailyChangePercentage) > 5
            }
            return false
        }
        
        if !highVolatilityStocks.isEmpty {
            insights.append(PortfolioInsight(
                type: .risk,
                priority: .medium,
                title: "High Volatility Detected",
                description: "Some stocks in your portfolio are showing high volatility, which increases risk.",
                recommendation: "Consider adding more stable assets or reducing position sizes in volatile stocks.",
                relatedStocks: highVolatilityStocks.map { $0.symbol }
            ))
        }
        
        return insights
    }
    
    private func analyzeOpportunities(_ portfolioItems: [PortfolioItem]) -> [PortfolioInsight] {
        var insights: [PortfolioInsight] = []
        
        // Check for sector opportunities
        let sectors = Set(portfolioItems.compactMap { item in
            Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.category
        })
        
        if sectors.count < 3 {
            insights.append(PortfolioInsight(
                type: .opportunity,
                priority: .medium,
                title: "Sector Diversification Opportunity",
                description: "Your portfolio is concentrated in \(sectors.count) sectors. Consider diversifying across more sectors.",
                recommendation: "Research and add stocks from underrepresented sectors like healthcare, finance, or energy.",
                relatedStocks: []
            ))
        }
        
        return insights
    }
    
    // MARK: - Computed Properties
    
    var highPriorityCount: Int {
        return insights.filter { $0.isHighPriority }.count
    }
    
    var recommendationCount: Int {
        return insights.filter { $0.type == .recommendation }.count
    }
    
    var opportunityCount: Int {
        return insights.filter { $0.type == .opportunity }.count
    }
    
    var unreadCount: Int {
        return insights.filter { !$0.isRead }.count
    }
    
    var hasInsights: Bool {
        return !insights.isEmpty
    }
}
