//
//  Stock.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

struct Stock: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let dailyChange: Double
    let chartPoints: [Double]?
    
    var dailyChangePercentage: Double {
        guard price > 0 else { return 0 }
        return (dailyChange / (price - dailyChange)) * 100
    }
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var formattedChange: String {
        let sign = dailyChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", dailyChange))"
    }
    
    var formattedChangePercentage: String {
        let sign = dailyChangePercentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", dailyChangePercentage))%"
    }
}
