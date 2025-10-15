//
//  SettingsView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var userSession = UserSession.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingExportView = false
    @State private var showingTransactionHistory = false
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                userProfileSection
                
                // App Preferences Section
                appPreferencesSection
                
                // Notifications Section
                notificationsSection
                
                // Data & Privacy Section
                dataPrivacySection
                
                // About Section
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingExportView) {
            ExportView()
        }
        .sheet(isPresented: $showingTransactionHistory) {
            TransactionHistoryView()
        }
    }
    
    // MARK: - User Profile Section
    
    private var userProfileSection: some View {
        Section {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("John Doe")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("john.doe@example.com")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Edit") {
                    // Handle edit profile
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Profile")
        }
    }
    
    // MARK: - App Preferences Section
    
    private var appPreferencesSection: some View {
        Section {
            // Theme Setting
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text("Theme")
                
                Spacer()
                
                Picker("Theme", selection: $viewModel.selectedTheme) {
                    ForEach(ThemeOption.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Currency Setting
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                Text("Currency")
                
                Spacer()
                
                Picker("Currency", selection: $viewModel.selectedCurrency) {
                    ForEach(CurrencyOption.allCases, id: \.self) { currency in
                        Text(currency.displayName).tag(currency)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Default Trade Type
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                Text("Default Trade Type")
                
                Spacer()
                
                Picker("Trade Type", selection: $viewModel.defaultTradeType) {
                    ForEach(SettingsTradeType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        } header: {
            Text("Preferences")
        }
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        Section {
            // Price Alerts
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.red)
                    .frame(width: 24)
                
                Text("Price Alerts")
                
                Spacer()
                
                Toggle("", isOn: $viewModel.priceAlertsEnabled)
            }
            
            // Portfolio Updates
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text("Portfolio Updates")
                
                Spacer()
                
                Toggle("", isOn: $viewModel.portfolioUpdatesEnabled)
            }
            
            // Market News
            HStack {
                Image(systemName: "newspaper.fill")
                    .foregroundColor(.purple)
                    .frame(width: 24)
                
                Text("Market News")
                
                Spacer()
                
                Toggle("", isOn: $viewModel.marketNewsEnabled)
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Receive notifications for important market updates and portfolio changes.")
        }
    }
    
    // MARK: - Data & Privacy Section
    
    private var dataPrivacySection: some View {
        Section {
            Button(action: {
                showingTransactionHistory = true
            }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Transaction History")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            Button(action: {
                showingExportView = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Export Data")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            Button(action: {
                viewModel.clearCache()
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    Text("Clear Cache")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            Button(action: {
                viewModel.resetSettings()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text("Reset Settings")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            Button(action: {
                userSession.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    Text("Sign Out")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.red)
        } header: {
            Text("Data & Privacy")
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text("Version")
                
                Spacer()
                
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                viewModel.showPrivacyPolicy()
            }) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.green)
                        .frame(width: 24)
                    
                    Text("Privacy Policy")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            Button(action: {
                viewModel.showTermsOfService()
            }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    Text("Terms of Service")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
        } header: {
            Text("About")
        }
    }
}

// MARK: - Supporting Types

enum ThemeOption: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

enum CurrencyOption: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    
    var displayName: String {
        switch self {
        case .usd: return "USD ($)"
        case .eur: return "EUR (€)"
        case .gbp: return "GBP (£)"
        case .jpy: return "JPY (¥)"
        }
    }
}

enum SettingsTradeType: String, CaseIterable {
    case buy = "buy"
    case sell = "sell"
    
    var displayName: String {
        switch self {
        case .buy: return "Buy"
        case .sell: return "Sell"
        }
    }
}

#Preview {
    SettingsView()
}
