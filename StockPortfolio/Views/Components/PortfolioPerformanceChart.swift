//
//  PortfolioPerformanceChart.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct PortfolioPerformanceChart: View {
    let performanceHistory: [PortfolioPerformance]
    
    @State private var selectedIndex: Int?
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Chart
            chartView
            
            // Legend
            if let selected = selectedPerformance {
                performanceDetails(selected)
            } else {
                defaultLegend
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            if performanceHistory.count > 1 {
                ZStack {
                    // Background grid
                    chartGrid(width: width, height: height)
                    
                    // Chart line
                    chartLine(width: width, height: height)
                    
                    // Interactive overlay
                    chartOverlay(width: width, height: height)
                }
            } else {
                // Empty state
                VStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No performance data available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: 150)
    }
    
    // MARK: - Chart Components
    
    private func chartGrid(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<5) { i in
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 1)
                if i < 4 {
                    Spacer()
                }
            }
        }
    }
    
    private func chartLine(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            guard !performanceHistory.isEmpty else { return }
            
            let minValue = performanceHistory.map(\.value).min() ?? 0
            let maxValue = performanceHistory.map(\.value).max() ?? 1
            let valueRange = maxValue - minValue
            
            guard valueRange > 0 else { return }
            
            let stepX = width / CGFloat(performanceHistory.count - 1)
            
            for (index, performance) in performanceHistory.enumerated() {
                let x = CGFloat(index) * stepX
                let normalizedValue = (performance.value - minValue) / valueRange
                let y = height - (normalizedValue * height)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(
            LinearGradient(
                colors: [.blue, .green],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
    
    private func chartOverlay(width: CGFloat, height: CGFloat) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let stepX = width / CGFloat(performanceHistory.count - 1)
                            let index = Int((value.location.x / stepX).rounded())
                            
                            if index >= 0 && index < performanceHistory.count {
                                selectedIndex = index
                            }
                        }
                        .onEnded { _ in
                            selectedIndex = nil
                        }
                )
        }
    }
    
    // MARK: - Performance Details
    
    private var selectedPerformance: PortfolioPerformance? {
        guard let index = selectedIndex, index < performanceHistory.count else { return nil }
        return performanceHistory[index]
    }
    
    private func performanceDetails(_ performance: PortfolioPerformance) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Portfolio Value")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(performance.formattedValue)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("Gain/Loss")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(performance.formattedGainLoss)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(performance.isPositive ? .green : .red)
            }
            
            HStack {
                Text("Date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(performance.date, style: .date)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
    
    private var defaultLegend: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Portfolio Performance")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let first = performanceHistory.first,
                   let last = performanceHistory.last {
                    let change = last.value - first.value
                    let changePercentage = first.value > 0 ? (change / first.value) * 100 : 0
                    
                    HStack {
                        Text(change >= 0 ? "+" : "")
                        Text(String(format: "%.2f", change))
                        Text("(\(String(format: "%.1f", changePercentage))%)")
                    }
                    .font(.caption)
                    .foregroundColor(change >= 0 ? .green : .red)
                }
            }
            
            Spacer()
            
            Text("Tap chart for details")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

#Preview {
    PortfolioPerformanceChart(
        performanceHistory: [
            PortfolioPerformance(
                date: Date().addingTimeInterval(-86400 * 7),
                value: 10000,
                invested: 9500,
                gainLoss: 500,
                gainLossPercentage: 5.26
            ),
            PortfolioPerformance(
                date: Date().addingTimeInterval(-86400 * 6),
                value: 10200,
                invested: 9600,
                gainLoss: 600,
                gainLossPercentage: 6.25
            ),
            PortfolioPerformance(
                date: Date().addingTimeInterval(-86400 * 5),
                value: 9800,
                invested: 9700,
                gainLoss: 100,
                gainLossPercentage: 1.03
            ),
            PortfolioPerformance(
                date: Date().addingTimeInterval(-86400 * 4),
                value: 10100,
                invested: 9800,
                gainLoss: 300,
                gainLossPercentage: 3.06
            ),
            PortfolioPerformance(
                date: Date().addingTimeInterval(-86400 * 3),
                value: 10300,
                invested: 9900,
                gainLoss: 400,
                gainLossPercentage: 4.04
            ),
            PortfolioPerformance(
                date: Date().addingTimeInterval(-86400 * 2),
                value: 10500,
                invested: 10000,
                gainLoss: 500,
                gainLossPercentage: 5.0
            ),
            PortfolioPerformance(
                date: Date().addingTimeInterval(-86400 * 1),
                value: 10700,
                invested: 10100,
                gainLoss: 600,
                gainLossPercentage: 5.94
            ),
            PortfolioPerformance(
                date: Date(),
                value: 10800,
                invested: 10200,
                gainLoss: 600,
                gainLossPercentage: 5.88
            )
        ]
    )
    .frame(height: 200)
    .padding()
}
