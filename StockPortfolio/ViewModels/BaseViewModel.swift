//
//  BaseViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var cancellables = Set<AnyCancellable>()
    
    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
