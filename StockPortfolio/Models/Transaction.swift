//
//  Transaction.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case buy = "BUY"
    case sell = "SELL"
}

struct Transaction: Codable, Identifiable {
    let id: UUID
    let symbol: String
    let quantity: Int
    let price: Double
    let type: TransactionType
    let timestamp: Date
    
    init(symbol: String, quantity: Int, price: Double, type: TransactionType) {
        self.id = UUID()
        self.symbol = symbol
        self.quantity = quantity
        self.price = price
        self.type = type
        self.timestamp = Date()
    }
    
    var totalValue: Double {
        return Double(quantity) * price
    }
    
    var formattedTotalValue: String {
        return String(format: "$%.2f", totalValue)
    }
}
