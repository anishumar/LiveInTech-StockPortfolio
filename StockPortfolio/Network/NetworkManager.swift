//
//  NetworkManager.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case timeout
    case serverError(Int)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .networkError(let message):
            return "Network error: \(message)"
        case .timeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error: \(code)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

class NetworkManager: ObservableObject {
    // MARK: - Singleton Pattern
    static let shared = NetworkManager()
    
    @Published var isOnline = true
    @Published var lastError: NetworkError?
    
    // MARK: - Configuration
    private let timeoutInterval: TimeInterval = 5.0
    private let retryAttempts = 3
    private let baseDelay: TimeInterval = 1.0
    
    // MARK: - API Configuration (Future: Real API endpoints)
    private let baseURL = "https://api.stockport.com" // Future: Real API base URL
    private let apiKey = "mock_api_key" // Future: Real API key
    
    // MARK: - Environment Configuration
    private let useMockData = true // Set to false when ready for real API calls
    
    private init() {
        // Initialize singleton
        print("🚀 NetworkManager singleton initialized")
        print("📡 Using \(useMockData ? "Mock" : "Real") API data")
    }
    
    // MARK: - Public API
    
    func fetchAllStocks() -> AnyPublisher<[Stock], NetworkError> {
        if useMockData {
            return fetchMockStocks()
        } else {
            return fetchRealStocks()
        }
    }
    
    func fetchStock(symbol: String) -> AnyPublisher<Stock, NetworkError> {
        return fetchAllStocks()
            .map { stocks in
                stocks.first { $0.symbol.uppercased() == symbol.uppercased() }
            }
            .compactMap { $0 }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    func searchStocks(query: String) -> AnyPublisher<[Stock], NetworkError> {
        return fetchAllStocks()
            .map { stocks in
                stocks.filter { stock in
                    stock.symbol.uppercased().contains(query.uppercased()) ||
                    stock.name.uppercased().contains(query.uppercased())
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mock API Implementation
    
    private func fetchMockStocks() -> AnyPublisher<[Stock], NetworkError> {
        return performMockNetworkCall { [weak self] in
            self?.loadMockStocksData()
        }
        .decode(type: [Stock].self, decoder: JSONDecoder())
        .mapError { error in
            if error is DecodingError {
                return NetworkError.decodingError
            }
            return NetworkError.unknownError
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Real API Implementation (Future)
    
    private func fetchRealStocks() -> AnyPublisher<[Stock], NetworkError> {
        // TODO: Implement real API calls
        // This is where you'll add real HTTP requests to your backend
        // Example implementation:
        /*
        let url = URL(string: "\(baseURL)/api/stocks")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Stock].self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                }
                return NetworkError.networkError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
        */
        
        // For now, return empty array
        return Just([])
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Network Simulation
    
    private func performMockNetworkCall<T>(dataProvider: @escaping () -> T?) -> AnyPublisher<Data, NetworkError> {
        return Future<Data, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError))
                return
            }
            
            // Simulate network delay with potential failure
            let delay = self.baseDelay + Double.random(in: 0...0.5)
            
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                // Simulate network failures (10% chance)
                if Double.random(in: 0...1) < 0.1 {
                    self.isOnline = false
                    promise(.failure(.networkError("Simulated network failure")))
                    return
                }
                
                self.isOnline = true
                
                // Simulate timeout (5% chance)
                if Double.random(in: 0...1) < 0.05 {
                    promise(.failure(.timeout))
                    return
                }
                
                // Simulate server error (3% chance)
                if Double.random(in: 0...1) < 0.03 {
                    promise(.failure(.serverError(500)))
                    return
                }
                
                // Return mock data
                guard let data = self.loadMockStocksData() else {
                    promise(.failure(.noData))
                    return
                }
                
                promise(.success(data))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Mock Data Loading
    
    private func loadMockStocksData() -> Data? {
        guard let path = Bundle.main.path(forResource: "stocks", ofType: "json") else {
            print("❌ Could not find stocks.json file")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            print("✅ Successfully loaded mock stocks data (\(data.count) bytes)")
            return data
        } catch {
            print("❌ Error loading stocks.json: \(error)")
            return nil
        }
    }
    
    // MARK: - Retry Logic with Exponential Backoff
    
    func fetchAllStocksWithRetry() -> AnyPublisher<[Stock], NetworkError> {
        return fetchAllStocks()
            .retry(retryAttempts)
            .catch { error -> AnyPublisher<[Stock], NetworkError> in
                print("❌ Network call failed after \(self.retryAttempts) attempts: \(error)")
                self.lastError = error
                self.isOnline = false
                return Just([])
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchStockWithRetry(symbol: String) -> AnyPublisher<Stock, NetworkError> {
        return fetchStock(symbol: symbol)
            .retry(retryAttempts)
            .catch { error -> AnyPublisher<Stock, NetworkError> in
                print("❌ Stock fetch failed after \(self.retryAttempts) attempts: \(error)")
                self.lastError = error
                self.isOnline = false
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Debug Methods
    
    func simulateNetworkFailure() {
        isOnline = false
        lastError = .networkError("Simulated failure for testing")
    }
    
    func simulateTimeout() {
        isOnline = false
        lastError = .timeout
    }
    
    func resetNetwork() {
        isOnline = true
        lastError = nil
    }
}
