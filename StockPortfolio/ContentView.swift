//
//  ContentView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome to StockPort!")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Your portfolio will be here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
