//
//  PriceAlert.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

enum AlertCondition: String, CaseIterable, Codable {
    case above = "above"
    case below = "below"
    case equals = "equals"
    
    var displayName: String {
        switch self {
        case .above: return "Above"
        case .below: return "Below"
        case .equals: return "Equals"
        }
    }
    
    var symbol: String {
        switch self {
        case .above: return ">"
        case .below: return "<"
        case .equals: return "="
        }
    }
}

enum AlertStatus: String, CaseIterable, Codable {
    case active = "active"
    case triggered = "triggered"
    case cancelled = "cancelled"
    case expired = "expired"
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .triggered: return "Triggered"
        case .cancelled: return "Cancelled"
        case .expired: return "Expired"
        }
    }
    
    var color: String {
        switch self {
        case .active: return "blue"
        case .triggered: return "green"
        case .cancelled: return "gray"
        case .expired: return "red"
        }
    }
}

struct PriceAlert: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let stockName: String
    let targetPrice: Double
    let condition: AlertCondition
    let status: AlertStatus
    let createdDate: Date
    let triggeredDate: Date?
    let isEnabled: Bool
    let notificationEnabled: Bool
    
    init(symbol: String, stockName: String, targetPrice: Double, condition: AlertCondition, isEnabled: Bool = true, notificationEnabled: Bool = true) {
        self.symbol = symbol
        self.stockName = stockName
        self.targetPrice = targetPrice
        self.condition = condition
        self.status = .active
        self.createdDate = Date()
        self.triggeredDate = nil
        self.isEnabled = isEnabled
        self.notificationEnabled = notificationEnabled
    }
    
    // MARK: - Computed Properties
    
    var formattedTargetPrice: String {
        return String(format: "$%.2f", targetPrice)
    }
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdDate)
    }
    
    var formattedTriggeredDate: String? {
        guard let triggeredDate = triggeredDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: triggeredDate)
    }
    
    var alertDescription: String {
        return "\(symbol) \(condition.symbol) \(formattedTargetPrice)"
    }
    
    var isActive: Bool {
        return status == .active && isEnabled
    }
    
    var canBeTriggered: Bool {
        return isActive && status == .active
    }
    
    // MARK: - Methods
    
    func checkTrigger(currentPrice: Double) -> Bool {
        guard canBeTriggered else { return false }
        
        switch condition {
        case .above:
            return currentPrice >= targetPrice
        case .below:
            return currentPrice <= targetPrice
        case .equals:
            return abs(currentPrice - targetPrice) < 0.01
        }
    }
    
    func trigger() -> PriceAlert {
        return PriceAlert(
            symbol: symbol,
            stockName: stockName,
            targetPrice: targetPrice,
            condition: condition,
            isEnabled: isEnabled,
            notificationEnabled: notificationEnabled
        )
    }
}

// MARK: - Price Alert Extensions

extension PriceAlert {
    static let mockAlerts: [PriceAlert] = [
        PriceAlert(symbol: "AAPL", stockName: "Apple Inc.", targetPrice: 180.0, condition: .above),
        PriceAlert(symbol: "TSLA", stockName: "Tesla, Inc.", targetPrice: 250.0, condition: .below),
        PriceAlert(symbol: "GOOGL", stockName: "Alphabet Inc.", targetPrice: 140.0, condition: .above)
    ]
}
