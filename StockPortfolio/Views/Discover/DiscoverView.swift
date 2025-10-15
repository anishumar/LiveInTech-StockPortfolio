//
//  DiscoverView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = AdvancedSearchViewModel()
    @State private var showingFilters = false
    @State private var showingWatchlist = false
    @State private var showingPriceAlerts = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                searchHeader
                
                // Filters Section
                if showingFilters {
                    filtersSection
                }
                
                // Content
                if viewModel.filteredStocks.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingWatchlist = true
                        }) {
                            Image(systemName: "eye")
                        }
                        
                        Button(action: {
                            showingPriceAlerts = true
                        }) {
                            Image(systemName: "bell")
                        }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingFilters.toggle()
                            }
                        }) {
                            Image(systemName: showingFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingWatchlist) {
            WatchlistView()
        }
        .sheet(isPresented: $showingPriceAlerts) {
            PriceAlertsView()
        }
        .onAppear {
            viewModel.loadAllStocks()
        }
    }
    
    // MARK: - Search Header
    
    private var searchHeader: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search stocks, ETFs, or symbols...", text: $viewModel.searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        viewModel.performSearch()
                    }
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                        viewModel.performSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
            
            // Quick Filters
            if !viewModel.isDefaultState {
                quickFilters
            }
        }
        .padding(.vertical, 8)
    }
    
    private var quickFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if !viewModel.selectedCategories.isEmpty {
                    ForEach(Array(viewModel.selectedCategories), id: \.self) { category in
                        FilterChip(
                            title: category.rawValue,
                            isSelected: true,
                            color: Color(category.color)
                        ) {
                            viewModel.toggleCategory(category)
                        }
                    }
                }
                
                if viewModel.showGainers {
                    FilterChip(
                        title: "Gainers",
                        isSelected: true,
                        color: .green
                    ) {
                        viewModel.toggleGainers()
                    }
                }
                
                if viewModel.showLosers {
                    FilterChip(
                        title: "Losers",
                        isSelected: true,
                        color: .red
                    ) {
                        viewModel.toggleLosers()
                    }
                }
                
                Button("Clear All") {
                    viewModel.clearFilters()
                }
                .font(.caption)
                .foregroundColor(Color.blue)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Filters Section
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Filters")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.filterCount) active")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                // Category Filter
                categoryFilter
                
                // Price Range Filter
                priceRangeFilter
                
                // Change Filter
                changeFilter
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.subheadline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(AssetCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: viewModel.selectedCategories.contains(category),
                        color: Color(category.color)
                    ) {
                        viewModel.toggleCategory(category)
                    }
                }
            }
        }
    }
    
    private var priceRangeFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price Range")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Text("$\(Int(viewModel.minPrice))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(value: $viewModel.minPrice, in: 0...1000, step: 10)
                    .accentColor(Color.blue)
                
                Text("$\(Int(viewModel.maxPrice))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var changeFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Change")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                FilterChip(
                    title: "Gainers",
                    isSelected: viewModel.showGainers,
                    color: .green
                ) {
                    viewModel.toggleGainers()
                }
                
                FilterChip(
                    title: "Losers",
                    isSelected: viewModel.showLosers,
                    color: .red
                ) {
                    viewModel.toggleLosers()
                }
                
                FilterChip(
                    title: "All",
                    isSelected: viewModel.showAll,
                    color: Color.blue
                ) {
                    viewModel.showAll = true
                }
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Stocks Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search terms or filters to find more stocks.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Clear Filters") {
                viewModel.clearFilters()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Content View
    
    private var contentView: some View {
        VStack(spacing: 0) {
            // Results Header
            resultsHeader
            
            // Results List
            resultsList
        }
    }
    
    private var resultsHeader: some View {
        HStack {
            Text("\(viewModel.filteredStocks.count) stocks found")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var resultsList: some View {
        List {
            ForEach(viewModel.filteredStocks) { stock in
                NavigationLink(destination: StockDetailView(stock: stock)) {
                    StockSearchRowView(stock: stock) {
                        // Handle stock selection
                        viewModel.selectStock(stock)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct StockDetailView: View {
    let stock: Stock
    @State private var showingTradeView = false
    @State private var showingAddToWatchlist = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Stock Header
            stockHeader
            
            // Stock Chart
            if stock.hasChartData {
                StockChartView(
                    chartPoints: stock.chartPoints ?? [],
                    isPositive: stock.dailyChange >= 0
                )
                .frame(height: 200)
            }
            
            // Stock Details
            stockDetails
            
            // Action Buttons
            actionButtons
            
            Spacer()
        }
        .padding()
        .navigationTitle(stock.symbol)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Trade") {
                    showingTradeView = true
                }
            }
        }
        .sheet(isPresented: $showingTradeView) {
            TradeView()
        }
        .sheet(isPresented: $showingAddToWatchlist) {
            AddToWatchlistView { selectedStock in
                // Handle adding to watchlist
            }
        }
    }
    
    private var stockHeader: some View {
        VStack(spacing: 8) {
            Text(stock.symbol)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(stock.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Text(String(format: "$%.2f", stock.price))
                    .font(.title)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    Image(systemName: stock.dailyChange >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                        .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                    
                    Text(String(format: "%.2f", abs(stock.dailyChange)))
                        .font(.subheadline)
                        .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                    
                    Text(String(format: "(%.2f%%)", stock.dailyChangePercentage))
                        .font(.subheadline)
                        .foregroundColor(stock.dailyChange >= 0 ? .green : .red)
                }
            }
        }
    }
    
    private var stockDetails: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Category")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(stock.category?.rawValue ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Market Cap")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("$1.2T") // Mock data
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Volume")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("45.2M") // Mock data
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private var actionButtons: some View {
        EmptyView()
    }
}

#Preview {
    DiscoverView()
}
