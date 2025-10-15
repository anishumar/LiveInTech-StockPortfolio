//
//  TradeViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

enum TradeType: String, CaseIterable {
    case buy = "Buy"
    case sell = "Sell"
}

class TradeViewModel: BaseViewModel {
    @Published var selectedStock: Stock?
    @Published var tradeType: TradeType = .buy
    @Published var quantity: String = ""
    @Published var searchQuery: String = ""
    @Published var searchResults: [Stock] = []
    @Published var currentPrice: Double = 0.0
    @Published var totalCost: Double = 0.0
    @Published var canExecuteTrade = false
    @Published var availableQuantity: Int = 0
    
    private let networkManager = NetworkManager.shared
    private let portfolioStore = PortfolioStore.shared
    
    override init() {
        super.init()
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    func searchStocks(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        networkManager.searchStocks(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] stocks in
                    self?.searchResults = stocks
                }
            )
            .store(in: &cancellables)
    }
    
    func selectStock(_ stock: Stock) {
        selectedStock = stock
        currentPrice = stock.price
        updateAvailableQuantity()
        calculateTotalCost()
    }
    
    func executeTrade() {
        guard let stock = selectedStock,
              let quantityInt = Int(quantity),
              quantityInt > 0 else {
            errorMessage = "Invalid quantity"
            return
        }
        
        isLoading = true
        
        switch tradeType {
        case .buy:
            executeBuy(stock: stock, quantity: quantityInt)
        case .sell:
            executeSell(stock: stock, quantity: quantityInt)
        }
    }
    
    func clearSelection() {
        selectedStock = nil
        quantity = ""
        searchQuery = ""
        searchResults = []
        currentPrice = 0.0
        totalCost = 0.0
        availableQuantity = 0
        clearError()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Listen to quantity changes
        $quantity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.calculateTotalCost()
                self?.validateTrade()
            }
            .store(in: &cancellables)
        
        // Listen to trade type changes
        $tradeType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAvailableQuantity()
                self?.validateTrade()
            }
            .store(in: &cancellables)
        
        // Listen to search query changes
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.searchStocks(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func executeBuy(stock: Stock, quantity: Int) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let portfolioItem = PortfolioItem(
                symbol: stock.symbol,
                quantity: quantity,
                averagePrice: stock.price
            )
            
            self.portfolioStore.addPortfolioItem(portfolioItem)
            
            let transaction = Transaction(
                symbol: stock.symbol,
                quantity: quantity,
                price: stock.price,
                type: .buy
            )
            
            self.portfolioStore.addTransaction(transaction)
            
            self.isLoading = false
            self.clearSelection()
        }
    }
    
    private func executeSell(stock: Stock, quantity: Int) {
        // Check if user has enough shares
        guard availableQuantity >= quantity else {
            errorMessage = "Insufficient shares to sell"
            isLoading = false
            return
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.portfolioStore.removePortfolioItem(symbol: stock.symbol, quantity: quantity)
            
            let transaction = Transaction(
                symbol: stock.symbol,
                quantity: quantity,
                price: stock.price,
                type: .sell
            )
            
            self.portfolioStore.addTransaction(transaction)
            
            self.isLoading = false
            self.clearSelection()
        }
    }
    
    private func updateAvailableQuantity() {
        guard let stock = selectedStock else {
            availableQuantity = 0
            return
        }
        
        availableQuantity = portfolioStore.portfolioItems
            .first { $0.symbol == stock.symbol }?.quantity ?? 0
    }
    
    private func calculateTotalCost() {
        guard let quantityInt = Int(quantity), quantityInt > 0 else {
            totalCost = 0.0
            return
        }
        
        totalCost = Double(quantityInt) * currentPrice
    }
    
    private func validateTrade() {
        // Clear previous errors
        clearError()
        
        guard !quantity.isEmpty else {
            canExecuteTrade = false
            return
        }
        
        // Validate quantity is numeric and positive
        guard let quantityInt = Int(quantity), quantityInt > 0 else {
            errorMessage = "Please enter a valid quantity (positive number)"
            canExecuteTrade = false
            return
        }
        
        // Validate quantity is not too large
        guard quantityInt <= 10000 else {
            errorMessage = "Maximum quantity allowed is 10,000 shares"
            canExecuteTrade = false
            return
        }
        
        switch tradeType {
        case .buy:
            // Validate total cost is reasonable (prevent accidental large purchases)
            let totalCost = Double(quantityInt) * currentPrice
            guard totalCost <= 1000000 else { // $1M limit
                errorMessage = "Maximum purchase amount is $1,000,000"
                canExecuteTrade = false
                return
            }
            canExecuteTrade = true
            
        case .sell:
            guard availableQuantity >= quantityInt else {
                errorMessage = "Insufficient shares. You own \(availableQuantity) shares"
                canExecuteTrade = false
                return
            }
            canExecuteTrade = true
        }
    }
    
    // MARK: - Computed Properties
    
    var formattedCurrentPrice: String {
        return String(format: "$%.2f", currentPrice)
    }
    
    var formattedTotalCost: String {
        return String(format: "$%.2f", totalCost)
    }
    
    var formattedAvailableQuantity: String {
        return "\(availableQuantity) shares available"
    }
    
    var tradeButtonTitle: String {
        switch tradeType {
        case .buy:
            return "Buy \(quantity.isEmpty ? "0" : quantity) Shares"
        case .sell:
            return "Sell \(quantity.isEmpty ? "0" : quantity) Shares"
        }
    }
    
    var hasSelectedStock: Bool {
        return selectedStock != nil
    }
    
    var canSell: Bool {
        return availableQuantity > 0
    }
}
