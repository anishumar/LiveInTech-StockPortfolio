//
//  PortfolioAnalytics.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

enum AssetCategory: String, CaseIterable, Codable {
    case equity = "Equity"
    case debt = "Debt"
    case hybrid = "Hybrid"
    case other = "Other"
    
    var color: String {
        switch self {
        case .equity: return "blue"
        case .debt: return "green"
        case .hybrid: return "orange"
        case .other: return "purple"
        }
    }
    
    var icon: String {
        switch self {
        case .equity: return "chart.line.uptrend.xyaxis"
        case .debt: return "shield.checkered"
        case .hybrid: return "circle.hexagongrid"
        case .other: return "questionmark.circle"
        }
    }
}

struct CategoryDistribution: Identifiable {
    let id = UUID()
    let category: AssetCategory
    let value: Double
    let percentage: Double
    let count: Int
    
    var formattedValue: String {
        return String(format: "$%.2f", value)
    }
    
    var formattedPercentage: String {
        return String(format: "%.1f%%", percentage)
    }
}

struct PortfolioPerformance: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let invested: Double
    let gainLoss: Double
    let gainLossPercentage: Double
    
    var formattedValue: String {
        return String(format: "$%.2f", value)
    }
    
    var formattedInvested: String {
        return String(format: "$%.2f", invested)
    }
    
    var formattedGainLoss: String {
        let sign = gainLoss >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", gainLoss))"
    }
    
    var formattedGainLossPercentage: String {
        let sign = gainLossPercentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", gainLossPercentage))%"
    }
    
    var isPositive: Bool {
        return gainLoss >= 0
    }
}

struct PortfolioMetrics {
    let totalInvested: Double
    let currentValue: Double
    let totalGainLoss: Double
    let totalGainLossPercentage: Double
    let roi: Double
    let annualizedReturn: Double
    let riskScore: Double
    let diversificationScore: Double
    
    var formattedTotalInvested: String {
        return String(format: "$%.2f", totalInvested)
    }
    
    var formattedCurrentValue: String {
        return String(format: "$%.2f", currentValue)
    }
    
    var formattedTotalGainLoss: String {
        let sign = totalGainLoss >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", totalGainLoss))"
    }
    
    var formattedTotalGainLossPercentage: String {
        let sign = totalGainLossPercentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", totalGainLossPercentage))%"
    }
    
    var formattedROI: String {
        let sign = roi >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", roi))%"
    }
    
    var formattedAnnualizedReturn: String {
        let sign = annualizedReturn >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", annualizedReturn))%"
    }
    
    var formattedRiskScore: String {
        return String(format: "%.1f/10", riskScore)
    }
    
    var formattedDiversificationScore: String {
        return String(format: "%.1f/10", diversificationScore)
    }
    
    var isPositive: Bool {
        return totalGainLoss >= 0
    }
    
    var riskLevel: String {
        switch riskScore {
        case 0..<3: return "Low"
        case 3..<6: return "Medium"
        case 6..<8: return "High"
        default: return "Very High"
        }
    }
    
    var diversificationLevel: String {
        switch diversificationScore {
        case 0..<3: return "Poor"
        case 3..<6: return "Fair"
        case 6..<8: return "Good"
        default: return "Excellent"
        }
    }
}
