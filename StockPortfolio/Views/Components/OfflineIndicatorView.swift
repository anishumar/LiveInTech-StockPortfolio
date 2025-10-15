//
//  OfflineIndicatorView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct OfflineIndicatorView: View {
    @StateObject private var networkManager = NetworkManager.shared
    
    var body: some View {
        if !networkManager.isOnline {
            HStack {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.red)
                
                Text("Offline - Showing cached data")
                    .font(.caption)
                    .foregroundColor(.red)
                
                Spacer()
                
                if let error = networkManager.lastError {
                    Text(error.localizedDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}

#Preview {
    VStack {
        OfflineIndicatorView()
        Spacer()
    }
}
