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
            ZStack {
                // Fill area under the curve
                Path { path in
                    guard !normalizedPoints.isEmpty else { return }
                    
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / Double(normalizedPoints.count - 1)
                    
                    // Start from bottom left
                    path.move(to: CGPoint(x: 0, y: height))
                    
                    // Draw the line with smooth curves
                    for (index, point) in normalizedPoints.enumerated() {
                        let x = Double(index) * stepX
                        let y = height * (1 - point)
                        
                        if index == 0 {
                            path.addLine(to: CGPoint(x: x, y: y))
                        } else {
                            let prevX = Double(index - 1) * stepX
                            let prevY = height * (1 - normalizedPoints[index - 1])
                            let controlX = (prevX + x) / 2
                            
                            path.addQuadCurve(
                                to: CGPoint(x: x, y: y),
                                control: CGPoint(x: controlX, y: (prevY + y) / 2)
                            )
                        }
                    }
                    
                    // Close the path to bottom right
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: isPositive ? [.green.opacity(0.15), .clear] : [.red.opacity(0.15), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Main line
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
                    
                    // Draw smooth curves
                    for (index, point) in normalizedPoints.enumerated() {
                        if index == 0 { continue }
                        
                        let x = Double(index) * stepX
                        let y = height * (1 - point)
                        let prevX = Double(index - 1) * stepX
                        let prevY = height * (1 - normalizedPoints[index - 1])
                        let controlX = (prevX + x) / 2
                        
                        path.addQuadCurve(
                            to: CGPoint(x: x, y: y),
                            control: CGPoint(x: controlX, y: (prevY + y) / 2)
                        )
                    }
                }
                .stroke(
                    isPositive ? Color.green : Color.red,
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .frame(height: 30)
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
