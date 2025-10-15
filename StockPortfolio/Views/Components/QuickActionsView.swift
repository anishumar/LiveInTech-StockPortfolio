//
//  QuickActionsView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct QuickActionsView: View {
    @State private var showingTradeView = false
    @State private var showingWatchlistView = false
    @State private var showingSettingsView = false
    @State private var showingPriceAlerts = false
    @State private var showingInsights = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Quick Actions Header
            HStack {
                Text("Quick Actions")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            
            // Quick Actions Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "Buy Stock",
                    icon: "plus.circle.fill",
                    color: .green,
                    action: { showingTradeView = true }
                )
                
                QuickActionCard(
                    title: "Watchlist",
                    icon: "eye.circle.fill",
                    color: .orange,
                    action: { showingWatchlistView = true }
                )
                
                QuickActionCard(
                    title: "Price Alerts",
                    icon: "bell.circle.fill",
                    color: .red,
                    action: { showingPriceAlerts = true }
                )
                
                QuickActionCard(
                    title: "Insights",
                    icon: "brain.head.profile",
                    color: .purple,
                    action: { showingInsights = true }
                )
                
                QuickActionCard(
                    title: "Settings",
                    icon: "gearshape.circle.fill",
                    color: .gray,
                    action: { showingSettingsView = true }
                )
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingTradeView) {
            TradeView()
        }
        .sheet(isPresented: $showingWatchlistView) {
            WatchlistView()
        }
        .sheet(isPresented: $showingPriceAlerts) {
            PriceAlertsView()
        }
        .sheet(isPresented: $showingInsights) {
            PortfolioInsightsView()
        }
        .sheet(isPresented: $showingSettingsView) {
            SettingsView()
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isPressed ? color.opacity(0.3) : .black.opacity(0.1),
                        radius: isPressed ? 8 : 4,
                        x: 0,
                        y: isPressed ? 4 : 2
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    QuickActionsView()
        .padding()
}
