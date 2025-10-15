//
//  HomeView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var userSession = UserSession.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Welcome to StockPort!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let user = userSession.currentUser {
                        Text("Hello, \(user.email)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
                
                // Placeholder content
                VStack(spacing: 16) {
                    Text("Portfolio will be here")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Your stock portfolio, transactions, and analytics will be displayed in this area.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Debug link (remove in production)
                    NavigationLink(destination: NetworkTestView()) {
                        Text("Test Network Layer")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                    }
                }
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    userSession.logout()
                }) {
                    Text("Sign Out")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
}
