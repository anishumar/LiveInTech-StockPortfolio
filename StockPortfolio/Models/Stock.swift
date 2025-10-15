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
    let category: AssetCategory?
    
    // Custom coding keys for JSON decoding
    enum CodingKeys: String, CodingKey {
        case symbol
        case name
        case price
        case dailyChange
        case chartPoints
        case category
    }
    
    // Custom initializer for manual creation
    init(symbol: String, name: String, price: Double, dailyChange: Double, chartPoints: [Double]? = nil, category: AssetCategory? = nil) {
        self.symbol = symbol
        self.name = name
        self.price = price
        self.dailyChange = dailyChange
        self.chartPoints = chartPoints
        self.category = category
    }
    
    // Custom initializer for JSON decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        dailyChange = try container.decode(Double.self, forKey: .dailyChange)
        chartPoints = try container.decodeIfPresent([Double].self, forKey: .chartPoints)
        category = try container.decodeIfPresent(AssetCategory.self, forKey: .category)
    }
    
    // Manual encoder for JSON encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(dailyChange, forKey: .dailyChange)
        try container.encodeIfPresent(chartPoints, forKey: .chartPoints)
        try container.encodeIfPresent(category, forKey: .category)
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
        Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: [170, 171, 172, 174, 174.26], category: .equity),
        Stock(symbol: "TSLA", name: "Tesla, Inc.", price: 258.14, dailyChange: 2.14, chartPoints: [240, 245, 250, 255, 258.14], category: .equity),
        Stock(symbol: "GOOGL", name: "Alphabet Inc.", price: 135.50, dailyChange: 1.8, chartPoints: [130, 132, 133, 134, 135.5], category: .equity),
        Stock(symbol: "MSFT", name: "Microsoft Corporation", price: 378.85, dailyChange: 5.67, chartPoints: [370.0, 375.2, 372.8, 376.5, 378.85], category: .equity),
        Stock(symbol: "AMZN", name: "Amazon.com, Inc.", price: 155.23, dailyChange: 1.89, chartPoints: [152.0, 154.5, 153.2, 155.8, 155.23], category: .equity),
        Stock(symbol: "META", name: "Meta Platforms, Inc.", price: 485.20, dailyChange: 8.45, chartPoints: [475.0, 480.2, 478.5, 482.1, 485.20], category: .equity),
        Stock(symbol: "NVDA", name: "NVIDIA Corporation", price: 875.28, dailyChange: 12.34, chartPoints: [860.0, 870.5, 865.2, 872.8, 875.28], category: .equity),
        Stock(symbol: "NFLX", name: "Netflix, Inc.", price: 612.45, dailyChange: -2.15, chartPoints: [615.0, 618.2, 610.5, 608.3, 612.45], category: .equity),
        Stock(symbol: "BND", name: "Vanguard Total Bond Market ETF", price: 78.45, dailyChange: 0.12, chartPoints: [78.2, 78.3, 78.4, 78.35, 78.45], category: .debt),
        Stock(symbol: "AGG", name: "iShares Core U.S. Aggregate Bond ETF", price: 95.67, dailyChange: -0.08, chartPoints: [95.8, 95.7, 95.6, 95.65, 95.67], category: .debt),
        Stock(symbol: "VTI", name: "Vanguard Total Stock Market ETF", price: 245.32, dailyChange: 1.45, chartPoints: [243.0, 244.5, 243.8, 245.1, 245.32], category: .hybrid),
        Stock(symbol: "SPY", name: "SPDR S&P 500 ETF Trust", price: 456.78, dailyChange: 2.34, chartPoints: [454.0, 455.5, 454.8, 456.2, 456.78], category: .hybrid)
    ]
    
    static func mockStock(symbol: String) -> Stock? {
        return mockStocks.first { $0.symbol == symbol }
    }
}
