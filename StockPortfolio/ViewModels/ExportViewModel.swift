//
//  ExportViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class ExportViewModel: BaseViewModel {
    // MARK: - Published Properties
    
    @Published var exportData: ExportData?
    @Published var isExporting = false
    @Published var exportFormat: ExportFormat = .csv
    @Published var includeTransactions = true
    @Published var includeWatchlist = true
    @Published var dateRange: DateRange = .all
    
    // MARK: - Dependencies
    
    private let portfolioStore = PortfolioStore.shared
    private let watchlistViewModel = WatchlistViewModel()
    
    // MARK: - Public Methods
    
    func generateExportData() {
        isExporting = true
        clearError()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.createExportData()
            self.isExporting = false
        }
    }
    
    func exportToCSV() -> String {
        guard let data = exportData else { return "" }
        
        var csvContent = ""
        
        // Portfolio Header
        csvContent += "Portfolio Export\n"
        csvContent += "Generated: \(DateFormatter.exportDateFormatter.string(from: data.exportDate))\n\n"
        
        // Portfolio Section
        csvContent += "PORTFOLIO HOLDINGS\n"
        csvContent += "Symbol,Name,Quantity,Average Price,Current Price,Total Value,Gain/Loss,Gain/Loss %\n"
        
        for item in data.portfolio {
            let currentPrice = Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.price ?? item.averagePrice
            let totalValue = currentPrice * Double(item.quantity)
            let gainLoss = totalValue - (item.averagePrice * Double(item.quantity))
            let gainLossPercentage = item.averagePrice > 0 ? (gainLoss / (item.averagePrice * Double(item.quantity))) * 100 : 0
            
            let stockName = Stock.mockStocks.first(where: { $0.symbol == item.symbol })?.name ?? item.symbol
            
            csvContent += "\(item.symbol),\(stockName),\(item.quantity),\(String(format: "%.2f", item.averagePrice)),\(String(format: "%.2f", currentPrice)),\(String(format: "%.2f", totalValue)),\(String(format: "%.2f", gainLoss)),\(String(format: "%.2f", gainLossPercentage))\n"
        }
        
        csvContent += "\n"
        
        // Transactions Section
        if includeTransactions && !data.transactions.isEmpty {
            csvContent += "TRANSACTIONS\n"
            csvContent += "Date,Type,Symbol,Quantity,Price,Total Value\n"
            
            let filteredTransactions = filterTransactionsByDateRange(data.transactions)
            
            for transaction in filteredTransactions {
                csvContent += "\(DateFormatter.exportDateFormatter.string(from: transaction.timestamp)),\(transaction.type.rawValue.capitalized),\(transaction.symbol),\(transaction.quantity),\(String(format: "%.2f", transaction.price)),\(String(format: "%.2f", transaction.totalValue))\n"
            }
            
            csvContent += "\n"
        }
        
        // Watchlist Section
        if includeWatchlist && !data.watchlist.isEmpty {
            csvContent += "WATCHLIST\n"
            csvContent += "Symbol,Name,Current Price,Daily Change,Daily Change %\n"
            
            for stock in data.watchlist {
                csvContent += "\(stock.symbol),\(stock.name),\(String(format: "%.2f", stock.price)),\(String(format: "%.2f", stock.dailyChange)),\(String(format: "%.2f", stock.dailyChangePercentage))\n"
            }
        }
        
        return csvContent
    }
    
    func exportToJSON() -> String {
        guard let data = exportData else { return "" }
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    // MARK: - Private Methods
    
    private func createExportData() {
        let portfolioItems = portfolioStore.portfolioItems
        let transactions = portfolioStore.transactions
        let watchlist = watchlistViewModel.watchlistStocks
        
        exportData = ExportData(
            portfolio: portfolioItems,
            transactions: transactions,
            watchlist: watchlist,
            exportDate: Date()
        )
    }
    
    private func filterTransactionsByDateRange(_ transactions: [Transaction]) -> [Transaction] {
        switch dateRange {
        case .all:
            return transactions
        case .lastWeek:
            let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
            return transactions.filter { $0.timestamp >= oneWeekAgo }
        case .lastMonth:
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return transactions.filter { $0.timestamp >= oneMonthAgo }
        case .lastYear:
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            return transactions.filter { $0.timestamp >= oneYearAgo }
        }
    }
}

// MARK: - Supporting Types

enum ExportFormat: String, CaseIterable {
    case csv = "csv"
    case json = "json"
    
    var displayName: String {
        switch self {
        case .csv: return "CSV"
        case .json: return "JSON"
        }
    }
    
    var fileExtension: String {
        return rawValue
    }
}

enum DateRange: String, CaseIterable {
    case all = "all"
    case lastWeek = "lastWeek"
    case lastMonth = "lastMonth"
    case lastYear = "lastYear"
    
    var displayName: String {
        switch self {
        case .all: return "All Time"
        case .lastWeek: return "Last Week"
        case .lastMonth: return "Last Month"
        case .lastYear: return "Last Year"
        }
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let exportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
