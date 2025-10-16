//
//  DiscoverViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class DiscoverViewModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var filteredStocks: [Stock] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.filterStocks(searchText)
            }
            .store(in: &cancellables)
    }
    
    func loadAllStocks() {
        isLoading = true
        errorMessage = nil
        
        networkManager.fetchAllStocksWithRetry()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] stocks in
                    self?.stocks = stocks
                    self?.filteredStocks = stocks
                }
            )
            .store(in: &cancellables)
    }
    
    private func filterStocks(_ searchText: String) {
        if searchText.isEmpty {
            filteredStocks = stocks
        } else {
            filteredStocks = stocks.filter { stock in
                stock.symbol.localizedCaseInsensitiveContains(searchText) ||
                stock.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
