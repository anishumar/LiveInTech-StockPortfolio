//
//  PortfolioViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

struct PortfolioStock: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    let currentPrice: Double
    let quantity: Int
    let averagePrice: Double
    let dailyChange: Double
    let totalValue: Double
    let gainLoss: Double
    let gainLossPercentage: Double
    
    var formattedCurrentPrice: String {
        return String(format: "$%.2f", currentPrice)
    }
    
    var formattedTotalValue: String {
        return String(format: "$%.2f", totalValue)
    }
    
    var formattedGainLoss: String {
        let sign = gainLoss >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", gainLoss))"
    }
    
    var formattedGainLossPercentage: String {
        let sign = gainLossPercentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", gainLossPercentage))%"
    }
    
    var isPositiveGain: Bool {
        return gainLoss >= 0
    }
    
    func toStock() -> Stock {
        // Find the original stock data to get additional properties
        if let originalStock = Stock.mockStocks.first(where: { $0.symbol == self.symbol }) {
            return originalStock
        } else {
            // Fallback: create a basic Stock from PortfolioStock data
            return Stock(
                symbol: self.symbol,
                name: self.name,
                price: self.currentPrice,
                dailyChange: self.dailyChange,
                chartPoints: []
            )
        }
    }
}

class PortfolioViewModel: BaseViewModel {
    @Published var portfolioStocks: [PortfolioStock] = []
    @Published var totalPortfolioValue: Double = 0.0
    @Published var totalGainLoss: Double = 0.0
    @Published var totalGainLossPercentage: Double = 0.0
    @Published var isRefreshing = false
    
    private let portfolioStore = PortfolioStore.shared
    private let networkManager = NetworkManager.shared
    
    override init() {
        super.init()
        setupBindings()
        loadPortfolio()
    }
    
    // MARK: - Public Methods
    
    func refreshPortfolio() {
        DispatchQueue.main.async { [weak self] in
            self?.isRefreshing = true
        }
        
        networkManager.fetchAllStocks()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isRefreshing = false
                        if case .failure(let error) = completion {
                            self?.handleError(error)
                        }
                    }
                },
                receiveValue: { [weak self] stocks in
                    DispatchQueue.main.async {
                        self?.updatePortfolioWithStocks(stocks)
                    }
                }
            )
            .store(in: &self.cancellables)
    }
    
    func getStockQuantity(symbol: String) -> Int {
        return portfolioStore.portfolioItems.first { $0.symbol == symbol }?.quantity ?? 0
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Listen to portfolio changes
        portfolioStore.$portfolioItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadPortfolio()
            }
            .store(in: &self.cancellables)
    }
    
    private func loadPortfolio() {
        // First load current stock prices
        networkManager.fetchAllStocks()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] stocks in
                    self?.updatePortfolioWithStocks(stocks)
                }
            )
            .store(in: &self.cancellables)
    }
    
    private func updatePortfolioWithStocks(_ stocks: [Stock]) {
        guard !stocks.isEmpty else {
            print("⚠️ No stocks received during refresh")
            return
        }
        
        let portfolioItems = portfolioStore.portfolioItems
        var updatedPortfolioStocks: [PortfolioStock] = []
        
        for item in portfolioItems {
            if let stock = stocks.first(where: { $0.symbol == item.symbol }) {
                let totalValue = Double(item.quantity) * stock.price
                let totalCost = Double(item.quantity) * item.averagePrice
                let gainLoss = totalValue - totalCost
                let gainLossPercentage = totalCost > 0 ? (gainLoss / totalCost) * 100 : 0
                
                let portfolioStock = PortfolioStock(
                    symbol: item.symbol,
                    name: stock.name,
                    currentPrice: stock.price,
                    quantity: item.quantity,
                    averagePrice: item.averagePrice,
                    dailyChange: stock.dailyChange,
                    totalValue: totalValue,
                    gainLoss: gainLoss,
                    gainLossPercentage: gainLossPercentage
                )
                
                updatedPortfolioStocks.append(portfolioStock)
            }
        }
        
        // Update on main thread to prevent UI crashes
        DispatchQueue.main.async { [weak self] in
            self?.portfolioStocks = updatedPortfolioStocks
            self?.calculateTotals()
        }
    }
    
    private func calculateTotals() {
        totalPortfolioValue = portfolioStocks.reduce(0) { $0 + $1.totalValue }
        
        let totalCost = portfolioStocks.reduce(0) { total, stock in
            total + (Double(stock.quantity) * stock.averagePrice)
        }
        
        totalGainLoss = totalPortfolioValue - totalCost
        totalGainLossPercentage = totalCost > 0 ? (totalGainLoss / totalCost) * 100 : 0
    }
    
    // MARK: - Computed Properties
    
    var formattedTotalValue: String {
        return String(format: "$%.2f", totalPortfolioValue)
    }
    
    var formattedTotalGainLoss: String {
        let sign = totalGainLoss >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", totalGainLoss))"
    }
    
    var formattedTotalGainLossPercentage: String {
        let sign = totalGainLossPercentage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", totalGainLossPercentage))%"
    }
    
    var isPositiveGain: Bool {
        return totalGainLoss >= 0
    }
    
    var hasPortfolioItems: Bool {
        return !portfolioStocks.isEmpty
    }
}
