//
//  PortfolioInsightsView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct PortfolioInsightsView: View {
    @StateObject private var viewModel = PortfolioInsightsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.insights.isEmpty {
                    emptyStateView
                } else {
                    insightsContent
                }
            }
            .navigationTitle("Portfolio Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        viewModel.generateInsights()
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Insights Available")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Build your portfolio to receive AI-powered insights and recommendations.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Generate Insights") {
                viewModel.generateInsights()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Insights Content
    
    private var insightsContent: some View {
        VStack(spacing: 0) {
            // Insights Summary
            insightsSummary
            
            // Insights List
            insightsList
        }
    }
    
    private var insightsSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Insights Summary")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.insights.count) insights")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                InsightSummaryCard(
                    title: "High Priority",
                    count: viewModel.highPriorityCount,
                    color: .red
                )
                
                InsightSummaryCard(
                    title: "Recommendations",
                    count: viewModel.recommendationCount,
                    color: Color.blue
                )
                
                InsightSummaryCard(
                    title: "Opportunities",
                    count: viewModel.opportunityCount,
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
    
    private var insightsList: some View {
        List {
            ForEach(viewModel.insights) { insight in
                InsightRowView(insight: insight) {
                    viewModel.markAsRead(insight)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct InsightSummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

struct InsightRowView: View {
    let insight: PortfolioInsight
    let onRead: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                // Icon
                Image(systemName: insight.type.icon)
                    .foregroundColor(Color(insight.type.color))
                    .font(.title2)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(insight.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if !insight.isRead {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                        
                        Spacer()
                        
                        // Priority Badge
                        Text(insight.priority.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(insight.priority.color))
                            )
                    }
                    
                    Text(insight.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(isExpanded ? nil : 2)
                }
                
                // Expand Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                    if !insight.isRead {
                        onRead()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Expanded Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Recommendation
                    if insight.hasRecommendation {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Recommendation")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.blue)
                            
                            Text(insight.recommendation!)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.1))
                                )
                        }
                    }
                    
                    // Related Stocks
                    if !insight.relatedStocks.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Related Stocks")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                ForEach(insight.relatedStocks, id: \.self) { symbol in
                                    Text(symbol)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.blue)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Date
                    Text(insight.formattedCreatedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    PortfolioInsightsView()
}
