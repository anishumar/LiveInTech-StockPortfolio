//
//  WatchlistViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine
import SwiftUI

class WatchlistViewModel: BaseViewModel {
    // MARK: - Published Properties
    
    @Published var watchlistStocks: [Stock] = []
    @Published var showingAddStock = false
    
    // MARK: - Dependencies
    
    private let userDefaults = UserDefaults.standard
    private let watchlistKey = "watchlistStocks"
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        loadWatchlist()
    }
    
    // MARK: - Public Methods
    
    func addToWatchlist(_ stock: Stock) {
        guard !watchlistStocks.contains(where: { $0.symbol == stock.symbol }) else {
            return // Stock already in watchlist
        }
        
        watchlistStocks.append(stock)
        saveWatchlist()
    }
    
    func removeFromWatchlist(_ stock: Stock) {
        watchlistStocks.removeAll { $0.symbol == stock.symbol }
        saveWatchlist()
    }
    
    func isInWatchlist(_ stock: Stock) -> Bool {
        return watchlistStocks.contains { $0.symbol == stock.symbol }
    }
    
    func refreshWatchlist() {
        // Refresh stock prices for watchlist items
        // This would typically fetch updated prices from the network
        // For now, we'll just reload the watchlist
        loadWatchlist()
    }
    
    // MARK: - Private Methods
    
    private func loadWatchlist() {
        guard let data = userDefaults.data(forKey: watchlistKey),
              let stocks = try? JSONDecoder().decode([Stock].self, from: data) else {
            watchlistStocks = []
            return
        }
        
        watchlistStocks = stocks
    }
    
    private func saveWatchlist() {
        guard let data = try? JSONEncoder().encode(watchlistStocks) else {
            return
        }
        
        userDefaults.set(data, forKey: watchlistKey)
    }
    
    // MARK: - Computed Properties
    
    var totalWatchlistValue: String {
        let total = watchlistStocks.reduce(0) { total, stock in
            total + stock.price
        }
        return String(format: "$%.2f", total)
    }
    
    var averageChange: String {
        guard !watchlistStocks.isEmpty else { return "0.00%" }
        
        let totalChange = watchlistStocks.reduce(0) { total, stock in
            total + stock.dailyChangePercentage
        }
        
        let average = totalChange / Double(watchlistStocks.count)
        return String(format: "%.2f%%", average)
    }
    
    var averageChangeColor: Color {
        guard !watchlistStocks.isEmpty else { return .secondary }
        
        let totalChange = watchlistStocks.reduce(0) { total, stock in
            total + stock.dailyChangePercentage
        }
        
        let average = totalChange / Double(watchlistStocks.count)
        return average >= 0 ? .green : .red
    }
    
    var gainersCount: Int {
        return watchlistStocks.filter { $0.dailyChange > 0 }.count
    }
    
    var losersCount: Int {
        return watchlistStocks.filter { $0.dailyChange < 0 }.count
    }
    
    var hasWatchlistItems: Bool {
        return !watchlistStocks.isEmpty
    }
}
