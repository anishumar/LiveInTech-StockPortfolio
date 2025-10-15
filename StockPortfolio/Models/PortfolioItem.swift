//
//  PortfolioItem.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

struct PortfolioItem: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let quantity: Int
    let averagePrice: Double
    let purchaseDate: Date
    
    init(symbol: String, quantity: Int, averagePrice: Double) {
        self.symbol = symbol
        self.quantity = quantity
        self.averagePrice = averagePrice
        self.purchaseDate = Date()
    }
}
