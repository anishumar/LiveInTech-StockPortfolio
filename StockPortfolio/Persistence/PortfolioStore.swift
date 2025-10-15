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
    
    // Concurrency safety
    private let queue = DispatchQueue(label: "com.stockport.portfolio", qos: .userInitiated)
    private let semaphore = DispatchSemaphore(value: 1)
    
    private init() {
        loadPortfolio()
        loadTransactions()
        seedSampleData()
    }
    
    func addPortfolioItem(_ item: PortfolioItem) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.semaphore.wait()
            defer { self.semaphore.signal() }
            
            DispatchQueue.main.async {
                if let existingIndex = self.portfolioItems.firstIndex(where: { $0.symbol == item.symbol }) {
                    let existing = self.portfolioItems[existingIndex]
                    let newQuantity = existing.quantity + item.quantity
                    let newAveragePrice = ((Double(existing.quantity) * existing.averagePrice) + (Double(item.quantity) * item.averagePrice)) / Double(newQuantity)
                    
                    self.portfolioItems[existingIndex] = PortfolioItem(
                        symbol: item.symbol,
                        quantity: newQuantity,
                        averagePrice: newAveragePrice
                    )
                } else {
                    self.portfolioItems.append(item)
                }
                self.savePortfolio()
            }
        }
    }
    
    func removePortfolioItem(symbol: String, quantity: Int) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.semaphore.wait()
            defer { self.semaphore.signal() }
            
            DispatchQueue.main.async {
                if let index = self.portfolioItems.firstIndex(where: { $0.symbol == symbol }) {
                    let existing = self.portfolioItems[index]
                    let newQuantity = existing.quantity - quantity
                    
                    if newQuantity <= 0 {
                        self.portfolioItems.remove(at: index)
                    } else {
                        self.portfolioItems[index] = PortfolioItem(
                            symbol: symbol,
                            quantity: newQuantity,
                            averagePrice: existing.averagePrice
                        )
                    }
                    self.savePortfolio()
                }
            }
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.semaphore.wait()
            defer { self.semaphore.signal() }
            
            DispatchQueue.main.async {
                self.transactions.append(transaction)
                self.saveTransactions()
            }
        }
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
