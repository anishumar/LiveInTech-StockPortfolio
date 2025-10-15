//
//  AdvancedSearchViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class AdvancedSearchViewModel: BaseViewModel {
    // MARK: - Published Properties
    
    @Published var searchQuery = ""
    @Published var filteredStocks: [Stock] = []
    @Published var showFilters = false
    @Published var selectedCategories: Set<AssetCategory> = []
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 1000
    @Published var showGainers = false
    @Published var showLosers = false
    @Published var showAll = true
    
    // MARK: - Dependencies
    
    private let networkManager = NetworkManager.shared
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupBindings()
        loadAllStocks()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Search query binding
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.performSearch()
            }
            .store(in: &cancellables)
        
        // Filter bindings
        Publishers.CombineLatest4(
            $selectedCategories,
            $minPrice,
            $maxPrice,
            Publishers.CombineLatest3($showGainers, $showLosers, $showAll)
        )
        .sink { [weak self] _ in
            self?.applyFilters()
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadAllStocks() {
        isLoading = true
        clearError()
        
        networkManager.fetchAllStocks()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] stocks in
                    self?.filteredStocks = stocks
                }
            )
            .store(in: &cancellables)
    }
    
    func performSearch() {
        applyFilters()
    }
    
    func clearFilters() {
        searchQuery = ""
        selectedCategories.removeAll()
        minPrice = 0
        maxPrice = 1000
        showGainers = false
        showLosers = false
        showAll = true
        showFilters = false
    }
    
    func toggleCategory(_ category: AssetCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
    
    func toggleGainers() {
        showGainers.toggle()
        if showGainers {
            showLosers = false
            showAll = false
        }
    }
    
    func toggleLosers() {
        showLosers.toggle()
        if showLosers {
            showGainers = false
            showAll = false
        }
    }
    
    func selectStock(_ stock: Stock) {
        // Handle stock selection - could navigate to trade view or add to watchlist
        print("Selected stock: \(stock.symbol)")
    }
    
    // MARK: - Private Methods
    
    private func applyFilters() {
        networkManager.fetchAllStocks()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] stocks in
                    self?.filteredStocks = self?.filterStocks(stocks) ?? []
                }
            )
            .store(in: &cancellables)
    }
    
    private func filterStocks(_ stocks: [Stock]) -> [Stock] {
        var filtered = stocks
        
        // Text search filter
        if !searchQuery.isEmpty {
            filtered = filtered.filter { stock in
                stock.symbol.localizedCaseInsensitiveContains(searchQuery) ||
                stock.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // Category filter
        if !selectedCategories.isEmpty {
            filtered = filtered.filter { stock in
                guard let category = stock.category else { return false }
                return selectedCategories.contains(category)
            }
        }
        
        // Price range filter
        filtered = filtered.filter { stock in
            stock.price >= minPrice && stock.price <= maxPrice
        }
        
        // Change filter
        if showGainers {
            filtered = filtered.filter { $0.dailyChange > 0 }
        } else if showLosers {
            filtered = filtered.filter { $0.dailyChange < 0 }
        }
        // If showAll is true, no additional filtering needed
        
        return filtered.sorted { $0.symbol < $1.symbol }
    }
    
    // MARK: - Computed Properties
    
    var isDefaultState: Bool {
        return searchQuery.isEmpty &&
               selectedCategories.isEmpty &&
               minPrice == 0 &&
               maxPrice == 1000 &&
               !showGainers &&
               !showLosers &&
               showAll
    }
    
    var hasActiveFilters: Bool {
        return !isDefaultState
    }
    
    var filterCount: Int {
        var count = 0
        if !selectedCategories.isEmpty { count += 1 }
        if minPrice > 0 || maxPrice < 1000 { count += 1 }
        if showGainers || showLosers { count += 1 }
        return count
    }
}
