//
//  PriceAlertsView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct PriceAlertsView: View {
    @StateObject private var viewModel = PriceAlertViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.hasAlerts {
                    alertsContent
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Price Alerts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Alert") {
                        viewModel.showingCreateAlert = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateAlert) {
                CreatePriceAlertView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Price Alerts")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Set up price alerts to get notified when stocks reach your target prices.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Create Alert") {
                viewModel.showingCreateAlert = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Alerts Content
    
    private var alertsContent: some View {
        VStack(spacing: 0) {
            // Alerts Summary
            alertsSummary
            
            // Alerts List
            alertsList
        }
    }
    
    private var alertsSummary: some View {
        HStack(spacing: 20) {
            SummaryCard(
                title: "Active",
                count: viewModel.activeAlertsCount,
                color: Color.blue
            )
            
            SummaryCard(
                title: "Triggered",
                count: viewModel.triggeredAlertsCount,
                color: .green
            )
        }
        .padding()
    }
    
    private var alertsList: some View {
        List {
            // Active Alerts Section
            if !viewModel.priceAlerts.isEmpty {
                Section("Active Alerts") {
                    ForEach(viewModel.priceAlerts) { alert in
                        PriceAlertRowView(alert: alert) {
                            viewModel.toggleAlert(alert)
                        } onDelete: {
                            viewModel.deleteAlert(alert)
                        }
                    }
                }
            }
            
            // Triggered Alerts Section
            if !viewModel.triggeredAlerts.isEmpty {
                Section("Triggered Alerts") {
                    ForEach(viewModel.triggeredAlerts) { alert in
                        TriggeredAlertRowView(alert: alert) {
                            viewModel.dismissAlert(alert)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct SummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

struct PriceAlertRowView: View {
    let alert: PriceAlert
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Stock Info
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(alert.stockName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Alert Details
            VStack(alignment: .trailing, spacing: 4) {
                Text(alert.alertDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(alert.formattedCreatedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Toggle Button
            Button(action: onToggle) {
                Image(systemName: alert.isEnabled ? "bell.fill" : "bell.slash.fill")
                    .foregroundColor(alert.isEnabled ? Color.blue : .gray)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
    }
}

struct TriggeredAlertRowView: View {
    let alert: PriceAlert
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Alert Icon
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
            
            // Stock Info
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(alert.stockName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Alert Details
            VStack(alignment: .trailing, spacing: 4) {
                Text(alert.alertDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let triggeredDate = alert.formattedTriggeredDate {
                    Text("Triggered: \(triggeredDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Dismiss Button
            Button("Dismiss") {
                onDismiss()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}

struct CreatePriceAlertView: View {
    @ObservedObject var viewModel: PriceAlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let stock = viewModel.selectedStock {
                    // Stock Info
                    stockInfoSection(stock)
                    
                    // Alert Configuration
                    alertConfigurationSection
                    
                    Spacer()
                } else {
                    Text("No stock selected")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .navigationTitle("Create Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveAlert()
                        dismiss()
                    }
                    .disabled(!viewModel.canCreateAlert)
                }
            }
        }
    }
    
    private func stockInfoSection(_ stock: Stock) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Stock")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(stock.symbol)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(stock.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: "$%.2f", stock.price))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(String(format: "%.2f", stock.dailyChange))
                        .font(.subheadline)
                        .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private var alertConfigurationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Alert Configuration")
                    .font(.headline)
                Spacer()
            }
            
            // Target Price
            VStack(alignment: .leading, spacing: 8) {
                Text("Target Price")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Enter target price", text: $viewModel.targetPrice)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
            
            // Condition
            VStack(alignment: .leading, spacing: 8) {
                Text("Condition")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Condition", selection: $viewModel.selectedCondition) {
                    ForEach(AlertCondition.allCases, id: \.self) { condition in
                        Text(condition.displayName).tag(condition)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Notifications
            HStack {
                Text("Enable Notifications")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Toggle("", isOn: $viewModel.notificationEnabled)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    PriceAlertsView()
}
