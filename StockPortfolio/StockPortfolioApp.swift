//
//  StockPortfolioApp.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

@main
struct StockPortfolioApp: App {
    @StateObject private var userSession = UserSession.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userSession.isLoggedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
            .animation(.easeInOut, value: userSession.isLoggedIn)
        }
    }
}
