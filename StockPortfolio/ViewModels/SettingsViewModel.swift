//
//  SettingsViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class SettingsViewModel: BaseViewModel {
    // MARK: - Published Properties
    
    @Published var selectedTheme: ThemeOption = .system
    @Published var selectedCurrency: CurrencyOption = .usd
    @Published var defaultTradeType: SettingsTradeType = .buy
    @Published var priceAlertsEnabled: Bool = true
    @Published var portfolioUpdatesEnabled: Bool = true
    @Published var marketNewsEnabled: Bool = false
    
    // MARK: - Dependencies
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys
    
    private let themeKey = "selectedTheme"
    private let currencyKey = "selectedCurrency"
    private let defaultTradeTypeKey = "defaultTradeType"
    private let priceAlertsKey = "priceAlertsEnabled"
    private let portfolioUpdatesKey = "portfolioUpdatesEnabled"
    private let marketNewsKey = "marketNewsEnabled"
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        loadSettings()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Save settings when they change
        $selectedTheme
            .sink { [weak self] theme in
                self?.saveTheme(theme)
            }
            .store(in: &cancellables)
        
        $selectedCurrency
            .sink { [weak self] currency in
                self?.saveCurrency(currency)
            }
            .store(in: &cancellables)
        
        $defaultTradeType
            .sink { [weak self] (tradeType: SettingsTradeType) in
                self?.saveDefaultTradeType(tradeType)
            }
            .store(in: &cancellables)
        
        $priceAlertsEnabled
            .sink { [weak self] enabled in
                self?.savePriceAlerts(enabled)
            }
            .store(in: &cancellables)
        
        $portfolioUpdatesEnabled
            .sink { [weak self] enabled in
                self?.savePortfolioUpdates(enabled)
            }
            .store(in: &cancellables)
        
        $marketNewsEnabled
            .sink { [weak self] enabled in
                self?.saveMarketNews(enabled)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func exportData() {
        // Export portfolio and transaction data
        let portfolioStore = PortfolioStore.shared
        let watchlistViewModel = WatchlistViewModel()
        
        let exportData = ExportData(
            portfolio: portfolioStore.portfolioItems,
            transactions: portfolioStore.transactions,
            watchlist: watchlistViewModel.watchlistStocks,
            exportDate: Date()
        )
        
        // In a real app, this would trigger a share sheet or save to files
        print("Exporting data: \(exportData)")
    }
    
    func clearCache() {
        // Clear cached data
        UserDefaults.standard.removeObject(forKey: "cachedStocks")
        UserDefaults.standard.removeObject(forKey: "cachedPortfolio")
        
        // Show success message
        print("Cache cleared successfully")
    }
    
    func resetSettings() {
        // Reset all settings to defaults
        selectedTheme = .system
        selectedCurrency = .usd
        defaultTradeType = SettingsTradeType.buy
        priceAlertsEnabled = true
        portfolioUpdatesEnabled = true
        marketNewsEnabled = false
        
        // Clear all saved settings
        userDefaults.removeObject(forKey: themeKey)
        userDefaults.removeObject(forKey: currencyKey)
        userDefaults.removeObject(forKey: defaultTradeTypeKey)
        userDefaults.removeObject(forKey: priceAlertsKey)
        userDefaults.removeObject(forKey: portfolioUpdatesKey)
        userDefaults.removeObject(forKey: marketNewsKey)
        
        print("Settings reset to defaults")
    }
    
    func showPrivacyPolicy() {
        // In a real app, this would open a web view or navigate to privacy policy
        print("Showing privacy policy")
    }
    
    func showTermsOfService() {
        // In a real app, this would open a web view or navigate to terms of service
        print("Showing terms of service")
    }
    
    // MARK: - Private Methods
    
    private func loadSettings() {
        // Load theme
        if let themeRawValue = userDefaults.string(forKey: themeKey),
           let theme = ThemeOption(rawValue: themeRawValue) {
            selectedTheme = theme
        }
        
        // Load currency
        if let currencyRawValue = userDefaults.string(forKey: currencyKey),
           let currency = CurrencyOption(rawValue: currencyRawValue) {
            selectedCurrency = currency
        }
        
        // Load default trade type
        if let tradeTypeRawValue = userDefaults.string(forKey: defaultTradeTypeKey),
           let tradeType = SettingsTradeType(rawValue: tradeTypeRawValue) {
            defaultTradeType = tradeType
        }
        
        // Load notification settings
        priceAlertsEnabled = userDefaults.object(forKey: priceAlertsKey) as? Bool ?? true
        portfolioUpdatesEnabled = userDefaults.object(forKey: portfolioUpdatesKey) as? Bool ?? true
        marketNewsEnabled = userDefaults.object(forKey: marketNewsKey) as? Bool ?? false
    }
    
    private func saveTheme(_ theme: ThemeOption) {
        userDefaults.set(theme.rawValue, forKey: themeKey)
    }
    
    private func saveCurrency(_ currency: CurrencyOption) {
        userDefaults.set(currency.rawValue, forKey: currencyKey)
    }
    
    private func saveDefaultTradeType(_ tradeType: SettingsTradeType) {
        userDefaults.set(tradeType.rawValue, forKey: defaultTradeTypeKey)
    }
    
    private func savePriceAlerts(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: priceAlertsKey)
    }
    
    private func savePortfolioUpdates(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: portfolioUpdatesKey)
    }
    
    private func saveMarketNews(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: marketNewsKey)
    }
}

// MARK: - Export Data Model

struct ExportData: Codable {
    let portfolio: [PortfolioItem]
    let transactions: [Transaction]
    let watchlist: [Stock]
    let exportDate: Date
}
