//
//  Stock.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

struct Stock: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let dailyChange: Double
    let chartPoints: [Double]?
    
    // Custom coding keys for JSON decoding
    enum CodingKeys: String, CodingKey {
        case symbol
        case name
        case price
        case dailyChange
        case chartPoints
    }
    
    // Custom initializer for manual creation
    init(symbol: String, name: String, price: Double, dailyChange: Double, chartPoints: [Double]? = nil) {
        self.symbol = symbol
        self.name = name
        self.price = price
        self.dailyChange = dailyChange
        self.chartPoints = chartPoints
    }
    
    // Custom initializer for JSON decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        dailyChange = try container.decode(Double.self, forKey: .dailyChange)
        chartPoints = try container.decodeIfPresent([Double].self, forKey: .chartPoints)
    }
    
    // Manual encoder for JSON encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(dailyChange, forKey: .dailyChange)
        try container.encodeIfPresent(chartPoints, forKey: .chartPoints)
    }
    
    // MARK: - Computed Properties
    
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
    
    var isPositiveChange: Bool {
        return dailyChange >= 0
    }
    
    var changeColor: String {
        return isPositiveChange ? "green" : "red"
    }
    
    // MARK: - Search Support
    
    func matches(query: String) -> Bool {
        let lowercaseQuery = query.lowercased()
        return symbol.lowercased().contains(lowercaseQuery) ||
               name.lowercased().contains(lowercaseQuery)
    }
    
    // MARK: - Chart Data
    
    var hasChartData: Bool {
        return chartPoints != nil && !(chartPoints?.isEmpty ?? true)
    }
    
    var chartDataPoints: [Double] {
        return chartPoints ?? []
    }
    
    // MARK: - Debug Support
    
    var debugDescription: String {
        return "Stock(symbol: \(symbol), name: \(name), price: \(price), change: \(dailyChange))"
    }
}

// MARK: - Stock Extensions

extension Stock {
    static let mockStocks: [Stock] = [
        Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: [170, 171, 172, 174, 174.26]),
        Stock(symbol: "TSLA", name: "Tesla, Inc.", price: 258.14, dailyChange: 2.14, chartPoints: [240, 245, 250, 255, 258.14]),
        Stock(symbol: "GOOGL", name: "Alphabet Inc.", price: 135.50, dailyChange: 1.8, chartPoints: [130, 132, 133, 134, 135.5])
    ]
    
    static func mockStock(symbol: String) -> Stock? {
        return mockStocks.first { $0.symbol == symbol }
    }
}
