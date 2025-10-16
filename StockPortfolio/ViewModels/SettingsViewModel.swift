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
    
    @Published var portfolioUpdatesEnabled: Bool = true
    @Published var marketNewsEnabled: Bool = false
    
    // MARK: - Dependencies
    
    private let userDefaults = UserDefaults.standard
    private let userStore = UserStore.shared
    private let userSession = UserSession.shared
    
    // MARK: - Keys
    
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
        portfolioUpdatesEnabled = true
        marketNewsEnabled = false
        
        // Clear all saved settings
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
        // Load notification settings
        portfolioUpdatesEnabled = userDefaults.object(forKey: portfolioUpdatesKey) as? Bool ?? true
        marketNewsEnabled = userDefaults.object(forKey: marketNewsKey) as? Bool ?? false
    }
    
    private func savePortfolioUpdates(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: portfolioUpdatesKey)
    }
    
    private func saveMarketNews(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: marketNewsKey)
    }
    
    // MARK: - User Profile Management
    
    func updateUserProfile(firstName: String, lastName: String, email: String) {
        guard let currentUser = userSession.currentUser else { return }
        
        // Create updated user with new firstName and lastName
        let updatedUser = User(
            email: currentUser.email, // Keep original email
            password: currentUser.password,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        // Update in UserStore
        userStore.updateUser(updatedUser)
        
        // Update in UserSession
        userSession.updateCurrentUser(updatedUser)
    }
}

// MARK: - Export Data Model

struct ExportData: Codable {
    let portfolio: [PortfolioItem]
    let transactions: [Transaction]
    let watchlist: [Stock]
    let exportDate: Date
}
