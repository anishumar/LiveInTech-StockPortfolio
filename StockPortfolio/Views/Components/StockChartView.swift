//
//  StockChartView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct StockChartView: View {
    let chartPoints: [Double]
    let isPositive: Bool
    
    private var minValue: Double {
        chartPoints.min() ?? 0
    }
    
    private var maxValue: Double {
        chartPoints.max() ?? 0
    }
    
    private var normalizedPoints: [Double] {
        let range = maxValue - minValue
        guard range > 0 else { return chartPoints }
        return chartPoints.map { ($0 - minValue) / range }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard !normalizedPoints.isEmpty else { return }
                
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / Double(normalizedPoints.count - 1)
                
                // Start the path
                let firstPoint = CGPoint(
                    x: 0,
                    y: height * (1 - normalizedPoints[0])
                )
                path.move(to: firstPoint)
                
                // Draw the line
                for (index, point) in normalizedPoints.enumerated() {
                    let x = Double(index) * stepX
                    let y = height * (1 - point)
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: isPositive ? [.green, .green.opacity(0.3)] : [.red, .red.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
            
            // Fill area under the curve
            Path { path in
                guard !normalizedPoints.isEmpty else { return }
                
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / Double(normalizedPoints.count - 1)
                
                // Start from bottom left
                path.move(to: CGPoint(x: 0, y: height))
                
                // Draw the line
                for (index, point) in normalizedPoints.enumerated() {
                    let x = Double(index) * stepX
                    let y = height * (1 - point)
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                // Close the path to bottom right
                path.addLine(to: CGPoint(x: width, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: isPositive ? [.green.opacity(0.2), .clear] : [.red.opacity(0.2), .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: 60)
    }
}

#Preview {
    VStack(spacing: 20) {
        StockChartView(
            chartPoints: [170, 171, 172, 174, 174.26],
            isPositive: false
        )
        .background(Color(.systemGray6))
        .cornerRadius(8)
        
        StockChartView(
            chartPoints: [240, 245, 250, 255, 258.14],
            isPositive: true
        )
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    .padding()
}
