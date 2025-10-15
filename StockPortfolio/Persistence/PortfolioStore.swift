//
//  PortfolioStore.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class PortfolioStore: ObservableObject {
    static let shared = PortfolioStore()
    
    @Published var portfolioItems: [PortfolioItem] = []
    @Published var transactions: [Transaction] = []
    
    private let userDefaults = UserDefaults.standard
    private let portfolioKey = "portfolioItems"
    private let transactionsKey = "transactions"
    
    private init() {
        loadPortfolio()
        loadTransactions()
        seedSampleData()
    }
    
    func addPortfolioItem(_ item: PortfolioItem) {
        if let existingIndex = portfolioItems.firstIndex(where: { $0.symbol == item.symbol }) {
            let existing = portfolioItems[existingIndex]
            let newQuantity = existing.quantity + item.quantity
            let newAveragePrice = ((Double(existing.quantity) * existing.averagePrice) + (Double(item.quantity) * item.averagePrice)) / Double(newQuantity)
            
            portfolioItems[existingIndex] = PortfolioItem(
                symbol: item.symbol,
                quantity: newQuantity,
                averagePrice: newAveragePrice
            )
        } else {
            portfolioItems.append(item)
        }
        savePortfolio()
    }
    
    func removePortfolioItem(symbol: String, quantity: Int) {
        if let index = portfolioItems.firstIndex(where: { $0.symbol == symbol }) {
            let existing = portfolioItems[index]
            let newQuantity = existing.quantity - quantity
            
            if newQuantity <= 0 {
                portfolioItems.remove(at: index)
            } else {
                portfolioItems[index] = PortfolioItem(
                    symbol: symbol,
                    quantity: newQuantity,
                    averagePrice: existing.averagePrice
                )
            }
            savePortfolio()
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    private func savePortfolio() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(portfolioItems) {
            userDefaults.set(encoded, forKey: portfolioKey)
        }
    }
    
    private func loadPortfolio() {
        if let data = userDefaults.data(forKey: portfolioKey) {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([PortfolioItem].self, from: data) {
                portfolioItems = items
            }
        }
    }
    
    private func saveTransactions() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(transactions) {
            userDefaults.set(encoded, forKey: transactionsKey)
        }
    }
    
    private func loadTransactions() {
        if let data = userDefaults.data(forKey: transactionsKey) {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([Transaction].self, from: data) {
                transactions = items
            }
        }
    }
    
    private func seedSampleData() {
        // Only seed if no data exists
        if portfolioItems.isEmpty {
            let sampleItems = [
                PortfolioItem(symbol: "AAPL", quantity: 2, averagePrice: 150.0),
                PortfolioItem(symbol: "TSLA", quantity: 1, averagePrice: 200.0)
            ]
            portfolioItems = sampleItems
            savePortfolio()
        }
    }
}
