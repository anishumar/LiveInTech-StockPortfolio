//
//  StockDetailView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct PortfolioStockDetailView: View {
    let stock: Stock
    @ObservedObject private var portfolioStore = PortfolioStore.shared
    @State private var currentHoldings: Int = 0
    @State private var averagePrice: Double = 0.0
    @State private var totalInvested: Double = 0.0
    @State private var currentValue: Double = 0.0
    @State private var totalGainLoss: Double = 0.0
    @State private var totalGainLossPercentage: Double = 0.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                headerSection
                
                // Current Holdings Section
                if currentHoldings > 0 {
                    holdingsSection
                }
                
                // Stock Information Section
                stockInfoSection
                
                // Price Chart Section
                if stock.hasChartData {
                    chartSection
                }
                
                // Company Description Section
                descriptionSection
            }
            .padding()
        }
        .navigationTitle(stock.symbol)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadPortfolioData()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(stock.symbol)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(stock.price, specifier: "%.2f")")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: stock.dailyChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                            .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                        
                        Text("$\(abs(stock.dailyChange), specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                        
                        Text("(\(stock.dailyChangePercentage, specifier: "%.2f")%)")
                            .font(.subheadline)
                            .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Holdings Section
    
    private var holdingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Holdings")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Shares Owned")
                    Spacer()
                    Text("\(currentHoldings)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Average Price")
                    Spacer()
                    Text("$\(averagePrice, specifier: "%.2f")")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Total Invested")
                    Spacer()
                    Text("$\(totalInvested, specifier: "%.2f")")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Current Value")
                    Spacer()
                    Text("$\(currentValue, specifier: "%.2f")")
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                HStack {
                    Text("Total Gain/Loss")
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: totalGainLoss >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                            .foregroundColor(totalGainLoss >= 0 ? .green : .red)
                        
                        Text("$\(abs(totalGainLoss), specifier: "%.2f")")
                            .fontWeight(.semibold)
                            .foregroundColor(totalGainLoss >= 0 ? .green : .red)
                        
                        Text("(\(totalGainLossPercentage, specifier: "%.2f")%)")
                            .fontWeight(.semibold)
                            .foregroundColor(totalGainLoss >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Stock Information Section
    
    private var stockInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Stock Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Current Price")
                    Spacer()
                    Text("$\(stock.price, specifier: "%.2f")")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Daily Change")
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: stock.dailyChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                            .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                        
                        Text("$\(abs(stock.dailyChange), specifier: "%.2f")")
                            .fontWeight(.semibold)
                            .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                    }
                }
                
                HStack {
                    Text("Daily Change %")
                    Spacer()
                    Text("\(stock.dailyChangePercentage, specifier: "%.2f")%")
                        .fontWeight(.semibold)
                        .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                }
                
                if let category = stock.category {
                    HStack {
                        Text("Category")
                        Spacer()
                        Text(category.rawValue)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(categoryColor(category).opacity(0.2))
                            .foregroundColor(categoryColor(category))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Chart Section
    
    private var chartSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Price Chart")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            StockChartView(
                chartPoints: stock.chartPoints ?? [],
                isPositive: stock.dailyChange >= 0
            )
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("About \(stock.symbol)")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(stockDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Helper Methods
    
    private func loadPortfolioData() {
        let portfolio = portfolioStore.portfolioItems
        
        if let item = portfolio.first(where: { $0.symbol == stock.symbol }) {
            currentHoldings = item.quantity
            averagePrice = item.averagePrice
            totalInvested = Double(item.quantity) * item.averagePrice
            currentValue = Double(item.quantity) * stock.price
            totalGainLoss = currentValue - totalInvested
            totalGainLossPercentage = totalInvested > 0 ? (totalGainLoss / totalInvested) * 100 : 0
        } else {
            currentHoldings = 0
            averagePrice = 0
            totalInvested = 0
            currentValue = 0
            totalGainLoss = 0
            totalGainLossPercentage = 0
        }
    }
    
    private func categoryColor(_ category: AssetCategory) -> Color {
        switch category {
        case .equity:
            return .blue
        case .debt:
            return .green
        case .hybrid:
            return .orange
        case .other:
            return .purple
        }
    }
    
    private var stockDescription: String {
        switch stock.symbol {
        case "AAPL":
            return "Apple Inc. is a multinational technology company that designs, develops, and sells consumer electronics, computer software, and online services. The company is known for its innovative products including the iPhone, iPad, Mac, and Apple Watch."
        case "GOOGL":
            return "Alphabet Inc. is a multinational conglomerate and the parent company of Google. It specializes in Internet-related services and products, including online advertising technologies, search, cloud computing, software, and hardware."
        case "MSFT":
            return "Microsoft Corporation is a multinational technology corporation that develops, manufactures, licenses, supports, and sells computer software, consumer electronics, personal computers, and related services."
        case "TSLA":
            return "Tesla, Inc. is an American electric vehicle and clean energy company. Tesla designs, manufactures, and sells electric vehicles, energy storage systems, and solar panels."
        case "AMD":
            return "Advanced Micro Devices, Inc. is a multinational semiconductor company that develops computer processors and related technologies for business and consumer markets."
        default:
            return "\(stock.name) is a publicly traded company. This stock represents ownership in the company and its performance is influenced by various market factors, company earnings, and industry trends."
        }
    }
}

#Preview {
    NavigationView {
        PortfolioStockDetailView(stock: Stock.mockStock(symbol: "AAPL")!)
    }
}
