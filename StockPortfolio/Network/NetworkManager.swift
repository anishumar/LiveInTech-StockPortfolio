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
        }
    }
}

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchAllStocks() -> AnyPublisher<[Stock], NetworkError> {
        return simulateNetworkCall()
            .decode(type: [Stock].self, decoder: JSONDecoder())
            .mapError { _ in NetworkError.decodingError }
            .eraseToAnyPublisher()
    }
    
    func fetchStock(symbol: String) -> AnyPublisher<Stock, NetworkError> {
        return simulateNetworkCall()
            .decode(type: [Stock].self, decoder: JSONDecoder())
            .map { stocks in
                stocks.first { $0.symbol == symbol } ?? stocks.first!
            }
            .mapError { _ in NetworkError.decodingError }
            .eraseToAnyPublisher()
    }
    
    private func simulateNetworkCall() -> AnyPublisher<Data, NetworkError> {
        return Future<Data, NetworkError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                guard let data = self.loadMockStocksData() else {
                    promise(.failure(.noData))
                    return
                }
                promise(.success(data))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func loadMockStocksData() -> Data? {
        guard let path = Bundle.main.path(forResource: "stocks", ofType: "json"),
              let data = NSData(contentsOfFile: path) as Data? else {
            return nil
        }
        return data
    }
}
