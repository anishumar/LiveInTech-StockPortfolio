//
//  PortfolioInsight.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

enum InsightType: String, CaseIterable, Codable {
    case recommendation = "recommendation"
    case warning = "warning"
    case opportunity = "opportunity"
    case risk = "risk"
    case performance = "performance"
    
    var displayName: String {
        switch self {
        case .recommendation: return "Recommendation"
        case .warning: return "Warning"
        case .opportunity: return "Opportunity"
        case .risk: return "Risk"
        case .performance: return "Performance"
        }
    }
    
    var icon: String {
        switch self {
        case .recommendation: return "lightbulb.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .opportunity: return "star.fill"
        case .risk: return "shield.fill"
        case .performance: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var color: String {
        switch self {
        case .recommendation: return "blue"
        case .warning: return "orange"
        case .opportunity: return "green"
        case .risk: return "red"
        case .performance: return "purple"
        }
    }
}

enum InsightPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "gray"
        case .medium: return "blue"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

struct PortfolioInsight: Identifiable, Codable {
    let id = UUID()
    let type: InsightType
    let priority: InsightPriority
    let title: String
    let description: String
    let recommendation: String?
    let relatedStocks: [String]
    let createdDate: Date
    let isRead: Bool
    
    init(type: InsightType, priority: InsightPriority, title: String, description: String, recommendation: String? = nil, relatedStocks: [String] = []) {
        self.type = type
        self.priority = priority
        self.title = title
        self.description = description
        self.recommendation = recommendation
        self.relatedStocks = relatedStocks
        self.createdDate = Date()
        self.isRead = false
    }
    
    // MARK: - Computed Properties
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdDate)
    }
    
    var isHighPriority: Bool {
        return priority == .high || priority == .critical
    }
    
    var hasRecommendation: Bool {
        return recommendation != nil && !recommendation!.isEmpty
    }
}

// MARK: - Portfolio Insight Extensions

extension PortfolioInsight {
    static let mockInsights: [PortfolioInsight] = [
        PortfolioInsight(
            type: .recommendation,
            priority: .medium,
            title: "Diversification Opportunity",
            description: "Your portfolio is heavily weighted towards technology stocks. Consider diversifying into other sectors like healthcare or finance.",
            recommendation: "Add healthcare ETFs like VHT or individual stocks like JNJ to balance your portfolio.",
            relatedStocks: ["AAPL", "GOOGL", "MSFT"]
        ),
        PortfolioInsight(
            type: .warning,
            priority: .high,
            title: "High Volatility Detected",
            description: "Your portfolio has shown increased volatility over the past week. This may indicate higher risk exposure.",
            recommendation: "Consider adding more stable assets like bonds or dividend-paying stocks to reduce volatility.",
            relatedStocks: ["TSLA", "NVDA"]
        ),
        PortfolioInsight(
            type: .opportunity,
            priority: .medium,
            title: "Sector Rotation Opportunity",
            description: "Energy sector is showing strong momentum. Your portfolio could benefit from exposure to this sector.",
            recommendation: "Consider adding energy ETFs like XLE or individual energy stocks.",
            relatedStocks: []
        ),
        PortfolioInsight(
            type: .performance,
            priority: .low,
            title: "Strong Performance Trend",
            description: "Your portfolio has outperformed the market by 5.2% over the past month. Keep up the good work!",
            recommendation: nil,
            relatedStocks: ["AAPL", "MSFT", "GOOGL"]
        ),
        PortfolioInsight(
            type: .risk,
            priority: .critical,
            title: "Concentration Risk",
            description: "Over 60% of your portfolio is concentrated in just 3 stocks. This creates significant concentration risk.",
            recommendation: "Diversify your holdings by reducing position sizes in your largest holdings and adding more stocks.",
            relatedStocks: ["AAPL", "TSLA", "GOOGL"]
        )
    ]
}
