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
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                userProfileSection
                
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
            Text("Export functionality will be implemented here")
                .navigationTitle("Export Data")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingExportView = false
                        }
                    }
                }
        }
        .sheet(isPresented: $showingTransactionHistory) {
            TransactionHistoryView()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }
    
    // MARK: - User Profile Section
    
    private var userProfileSection: some View {
        Section {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(userSession.currentUser?.fullName ?? "User")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(userSession.currentUser?.email ?? "No email")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Edit") {
                    showingEditProfile = true
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Profile")
        }
    }
    
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        Section {
            // Portfolio Updates
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(Color.blue)
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
                        .foregroundColor(Color.blue)
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
                        .foregroundColor(Color.blue)
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
                    .foregroundColor(Color.blue)
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


#Preview {
    SettingsView()
}
