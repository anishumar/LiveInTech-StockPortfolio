//
//  AdvancedSearchView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct AdvancedSearchView: View {
    @StateObject private var viewModel = AdvancedSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Filters Section
                filtersSection
                
                // Results Section
                resultsSection
            }
            .navigationTitle("Search Stocks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        viewModel.clearFilters()
                    }
                    .disabled(viewModel.isDefaultState)
                }
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search stocks...", text: $viewModel.searchQuery)
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
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
    
    // MARK: - Filters Section
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Filters")
                    .font(.headline)
                Spacer()
                Button(viewModel.showFilters ? "Hide" : "Show") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.showFilters.toggle()
                    }
                }
                .font(.subheadline)
                .foregroundColor(Color.blue)
            }
            .padding(.horizontal)
            
            if viewModel.showFilters {
                VStack(spacing: 16) {
                    // Category Filter
                    categoryFilter
                    
                    // Price Range Filter
                    priceRangeFilter
                    
                    // Change Filter
                    changeFilter
                }
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
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
    
    // MARK: - Results Section
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Results (\(viewModel.filteredStocks.count))")
                    .font(.headline)
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal)
            
            if viewModel.filteredStocks.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                resultsList
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No stocks found")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var resultsList: some View {
        List(viewModel.filteredStocks) { stock in
            StockSearchRowView(stock: stock) {
                // Handle stock selection
                viewModel.selectStock(stock)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AdvancedSearchView()
}
