//
//  PortfolioAnalyticsView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct PortfolioAnalyticsView: View {
    @StateObject private var viewModel: PortfolioAnalyticsViewModel = PortfolioAnalyticsViewModel()
    @State private var showingSettings = false
    @State private var selectedTimeframe: Timeframe = .month
    
    enum Timeframe: String, CaseIterable {
        case week = "1W"
        case month = "1M"
        case quarter = "3M"
        case year = "1Y"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.hasAnalyticsData {
                        analyticsContent
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Portfolio Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape")
                        }
                        
                        Button(action: {
                            viewModel.refreshAnalytics()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .refreshable {
                viewModel.refreshAnalytics()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading analytics...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Analytics Data")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start building your portfolio to see detailed analytics and insights.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Go to Portfolio") {
                // Navigate to portfolio
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Analytics Content
    
    private var analyticsContent: some View {
        VStack(spacing: 20) {
            // Portfolio Health Score
            portfolioHealthCard
            
            // Key Metrics
            keyMetricsSection
            
            // Performance Graph
            performanceGraphSection
            
            // Category Distribution
            categoryDistributionSection
            
            // Performance Metrics
            performanceMetricsSection
        }
    }
    
    // MARK: - Portfolio Health Card
    
    private var portfolioHealthCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Portfolio Health")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.formattedHealthScore)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(healthScoreColor)
                    
                    Text(viewModel.healthLevel)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Health indicator
                Circle()
                    .fill(healthScoreColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("\(Int(viewModel.portfolioHealthScore))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private var healthScoreColor: Color {
        switch viewModel.portfolioHealthScore {
        case 0..<3: return .red
        case 3..<6: return .orange
        case 6..<8: return .yellow
        default: return .green
        }
    }
    
    // MARK: - Key Metrics Section
    
    private var keyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Metrics")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                if let metrics = viewModel.portfolioMetrics {
                    MetricCard(
                        title: "Total Invested",
                        value: metrics.formattedTotalInvested,
                        icon: "dollarsign.circle.fill",
                        color: .blue
                    )
                    
                    MetricCard(
                        title: "Current Value",
                        value: metrics.formattedCurrentValue,
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                    
                    MetricCard(
                        title: "Total Gain/Loss",
                        value: metrics.formattedTotalGainLoss,
                        icon: metrics.isPositive ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                        color: metrics.isPositive ? .green : .red
                    )
                    
                    MetricCard(
                        title: "ROI",
                        value: metrics.formattedROI,
                        icon: "percent",
                        color: metrics.isPositive ? .green : .red
                    )
                }
            }
        }
    }
    
    // MARK: - Performance Graph Section
    
    private var performanceGraphSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Portfolio Performance")
                    .font(.headline)
                
                Spacer()
                
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            .padding(.horizontal)
            
            PortfolioPerformanceChart(performanceHistory: viewModel.performanceHistory)
                .frame(height: 200)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Category Distribution Section
    
    private var categoryDistributionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Asset Allocation")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.categoryDistribution.isEmpty {
                Text("No category data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(viewModel.categoryDistribution) { distribution in
                        CategoryCard(distribution: distribution)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Performance Metrics Section
    
    private var performanceMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Metrics")
                .font(.headline)
                .padding(.horizontal)
            
            if let metrics = viewModel.portfolioMetrics {
                VStack(spacing: 12) {
                    PerformanceMetricRow(
                        title: "Annualized Return",
                        value: metrics.formattedAnnualizedReturn,
                        color: metrics.isPositive ? .green : .red
                    )
                    
                    PerformanceMetricRow(
                        title: "Risk Score",
                        value: "\(metrics.riskLevel) (\(metrics.formattedRiskScore))",
                        color: riskColor(metrics.riskScore)
                    )
                    
                    PerformanceMetricRow(
                        title: "Diversification",
                        value: "\(metrics.diversificationLevel) (\(metrics.formattedDiversificationScore))",
                        color: diversificationColor(metrics.diversificationScore)
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func riskColor(_ score: Double) -> Color {
        switch score {
        case 0..<3: return .green
        case 3..<6: return .yellow
        case 6..<8: return .orange
        default: return .red
        }
    }
    
    private func diversificationColor(_ score: Double) -> Color {
        switch score {
        case 0..<3: return .red
        case 3..<6: return .orange
        case 6..<8: return .yellow
        default: return .green
        }
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

struct CategoryCard: View {
    let distribution: CategoryDistribution
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: distribution.category.icon)
                    .foregroundColor(Color(distribution.category.color))
                Text(distribution.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack {
                Text(distribution.formattedValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(distribution.formattedPercentage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color(distribution.category.color))
                        .frame(width: geometry.size.width * (distribution.percentage / 100), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

struct PerformanceMetricRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PortfolioAnalyticsView()
}
