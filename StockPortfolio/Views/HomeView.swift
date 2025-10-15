//
//  HomeView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var userSession = UserSession.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Portfolio Tab
            PortfolioView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Portfolio")
                }
                .tag(0)
            
            // Debug Tab (remove in production)
            NetworkTestView()
                .tabItem {
                    Image(systemName: "wrench.and.screwdriver")
                    Text("Debug")
                }
                .tag(1)
        }
        .overlay(alignment: .topTrailing) {
            // Logout Button
            Button(action: {
                userSession.logout()
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
                    .padding()
            }
            .padding(.top, 8)
            .padding(.trailing, 8)
        }
    }
}

#Preview {
    HomeView()
}
