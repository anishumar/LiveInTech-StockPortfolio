//
//  StockPortfolioTests.swift
//  StockPortfolioTests
//
//  Created by Anish Umar on 15/10/25.
//

import XCTest
@testable import StockPortfolio

final class StockPortfolioTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught thrown exception.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

// MARK: - AuthViewModel Tests
class AuthViewModelTests: XCTestCase {
    var authViewModel: AuthViewModel!
    
    override func setUpWithError() throws {
        authViewModel = AuthViewModel()
    }
    
    override func tearDownWithError() throws {
        authViewModel = nil
    }
    
    func testEmailValidation() throws {
        // Valid emails
        XCTAssertTrue(authViewModel.validateEmail("test@example.com"))
        XCTAssertTrue(authViewModel.validateEmail("user.name@domain.co.uk"))
        XCTAssertTrue(authViewModel.validateEmail("test+tag@example.org"))
        
        // Invalid emails
        XCTAssertFalse(authViewModel.validateEmail("invalid-email"))
        XCTAssertFalse(authViewModel.validateEmail("@example.com"))
        XCTAssertFalse(authViewModel.validateEmail("test@"))
        XCTAssertFalse(authViewModel.validateEmail(""))
    }
    
    func testPasswordValidation() throws {
        // Valid passwords (8+ characters)
        XCTAssertTrue(authViewModel.validatePassword("password123"))
        XCTAssertTrue(authViewModel.validatePassword("12345678"))
        XCTAssertTrue(authViewModel.validatePassword("verylongpassword"))
        
        // Invalid passwords (less than 8 characters)
        XCTAssertFalse(authViewModel.validatePassword("1234567"))
        XCTAssertFalse(authViewModel.validatePassword("short"))
        XCTAssertFalse(authViewModel.validatePassword(""))
    }
    
    func testConfirmPasswordValidation() throws {
        // Matching passwords
        XCTAssertTrue(authViewModel.validateConfirmPassword(password: "password123", confirmPassword: "password123"))
        
        // Non-matching passwords
        XCTAssertFalse(authViewModel.validateConfirmPassword(password: "password123", confirmPassword: "password456"))
        XCTAssertFalse(authViewModel.validateConfirmPassword(password: "password123", confirmPassword: ""))
    }
}

// MARK: - NetworkManager Tests
class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        networkManager = NetworkManager.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        networkManager = nil
    }
    
    func testFetchAllStocks() throws {
        let expectation = XCTestExpectation(description: "Fetch all stocks")
        
        networkManager.fetchAllStocks()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Network call failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { stocks in
                    XCTAssertFalse(stocks.isEmpty, "Should return stocks")
                    XCTAssertTrue(stocks.count > 0, "Should have at least one stock")
                    print("✅ Fetched \(stocks.count) stocks")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchStockBySymbol() throws {
        let expectation = XCTestExpectation(description: "Fetch stock by symbol")
        
        networkManager.fetchStock(symbol: "AAPL")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Network call failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { stock in
                    XCTAssertEqual(stock.symbol, "AAPL", "Should return AAPL stock")
                    XCTAssertFalse(stock.name.isEmpty, "Stock should have a name")
                    XCTAssertTrue(stock.price > 0, "Stock should have a positive price")
                    print("✅ Fetched stock: \(stock.debugDescription)")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testSearchStocks() throws {
        let expectation = XCTestExpectation(description: "Search stocks")
        
        networkManager.searchStocks(query: "Apple")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Search failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { results in
                    XCTAssertFalse(results.isEmpty, "Should find Apple-related stocks")
                    print("✅ Found \(results.count) stocks matching 'Apple'")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testNetworkErrorHandling() throws {
        let expectation = XCTestExpectation(description: "Test network error handling")
        
        // Simulate network failure
        networkManager.simulateNetworkFailure()
        
        networkManager.fetchAllStocks()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertNotNil(error, "Should receive network error")
                        print("✅ Received expected network error: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Should not receive data when network is offline")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testRetryLogic() throws {
        let expectation = XCTestExpectation(description: "Test retry logic")
        
        networkManager.fetchAllStocksWithRetry()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Retry failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { stocks in
                    print("✅ Retry succeeded with \(stocks.count) stocks")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 15.0)
    }
}

// MARK: - Stock Model Tests
class StockModelTests: XCTestCase {
    
    func testStockInitialization() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: [170, 171, 172, 174, 174.26])
        
        XCTAssertEqual(stock.symbol, "AAPL")
        XCTAssertEqual(stock.name, "Apple Inc.")
        XCTAssertEqual(stock.price, 174.26)
        XCTAssertEqual(stock.dailyChange, -0.42)
        XCTAssertFalse(stock.isPositiveChange)
        XCTAssertEqual(stock.changeColor, "red")
    }
    
    func testStockFormatting() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        
        XCTAssertEqual(stock.formattedPrice, "$174.26")
        XCTAssertEqual(stock.formattedChange, "-0.42")
        XCTAssertTrue(stock.formattedChangePercentage.contains("-"))
    }
    
    func testStockSearch() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        
        XCTAssertTrue(stock.matches(query: "AAPL"))
        XCTAssertTrue(stock.matches(query: "apple"))
        XCTAssertTrue(stock.matches(query: "Apple"))
        XCTAssertFalse(stock.matches(query: "GOOGL"))
        XCTAssertFalse(stock.matches(query: "Microsoft"))
    }
    
    func testStockEquality() throws {
        let stock1 = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        let stock2 = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        let stock3 = Stock(symbol: "GOOGL", name: "Alphabet Inc.", price: 135.50, dailyChange: 1.8, chartPoints: nil)
        
        XCTAssertEqual(stock1, stock2)
        XCTAssertNotEqual(stock1, stock3)
    }
    
    func testStockHashable() throws {
        let stock1 = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        let stock2 = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        
        XCTAssertEqual(stock1.hashValue, stock2.hashValue)
    }
}

// MARK: - PortfolioViewModel Tests
class PortfolioViewModelTests: XCTestCase {
    var portfolioViewModel: PortfolioViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        portfolioViewModel = PortfolioViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        portfolioViewModel = nil
    }
    
    func testPortfolioStockInitialization() throws {
        let portfolioStock = PortfolioStock(
            symbol: "AAPL",
            name: "Apple Inc.",
            currentPrice: 174.26,
            quantity: 2,
            averagePrice: 150.0,
            dailyChange: -0.42,
            totalValue: 348.52,
            gainLoss: 48.52,
            gainLossPercentage: 16.17
        )
        
        XCTAssertEqual(portfolioStock.symbol, "AAPL")
        XCTAssertEqual(portfolioStock.name, "Apple Inc.")
        XCTAssertEqual(portfolioStock.currentPrice, 174.26)
        XCTAssertEqual(portfolioStock.quantity, 2)
        XCTAssertEqual(portfolioStock.averagePrice, 150.0)
        XCTAssertEqual(portfolioStock.totalValue, 348.52)
        XCTAssertEqual(portfolioStock.gainLoss, 48.52)
        XCTAssertEqual(portfolioStock.gainLossPercentage, 16.17)
        XCTAssertTrue(portfolioStock.isPositiveGain)
    }
    
    func testPortfolioStockFormatting() throws {
        let portfolioStock = PortfolioStock(
            symbol: "AAPL",
            name: "Apple Inc.",
            currentPrice: 174.26,
            quantity: 2,
            averagePrice: 150.0,
            dailyChange: -0.42,
            totalValue: 348.52,
            gainLoss: 48.52,
            gainLossPercentage: 16.17
        )
        
        XCTAssertEqual(portfolioStock.formattedCurrentPrice, "$174.26")
        XCTAssertEqual(portfolioStock.formattedTotalValue, "$348.52")
        XCTAssertEqual(portfolioStock.formattedGainLoss, "+48.52")
        XCTAssertEqual(portfolioStock.formattedGainLossPercentage, "+16.17%")
    }
    
    func testPortfolioStockNegativeGain() throws {
        let portfolioStock = PortfolioStock(
            symbol: "TSLA",
            name: "Tesla, Inc.",
            currentPrice: 200.0,
            quantity: 1,
            averagePrice: 250.0,
            dailyChange: 2.14,
            totalValue: 200.0,
            gainLoss: -50.0,
            gainLossPercentage: -20.0
        )
        
        XCTAssertFalse(portfolioStock.isPositiveGain)
        XCTAssertEqual(portfolioStock.formattedGainLoss, "-50.00")
        XCTAssertEqual(portfolioStock.formattedGainLossPercentage, "-20.00%")
    }
    
    func testPortfolioViewModelInitialization() throws {
        XCTAssertNotNil(portfolioViewModel)
        XCTAssertEqual(portfolioViewModel.totalPortfolioValue, 0.0)
        XCTAssertEqual(portfolioViewModel.totalGainLoss, 0.0)
        XCTAssertEqual(portfolioViewModel.totalGainLossPercentage, 0.0)
        XCTAssertFalse(portfolioViewModel.isRefreshing)
        XCTAssertFalse(portfolioViewModel.hasPortfolioItems)
    }
    
    func testPortfolioViewModelFormatting() throws {
        // Test with sample data
        portfolioViewModel.totalPortfolioValue = 1000.50
        portfolioViewModel.totalGainLoss = 50.25
        portfolioViewModel.totalGainLossPercentage = 5.25
        
        XCTAssertEqual(portfolioViewModel.formattedTotalValue, "$1000.50")
        XCTAssertEqual(portfolioViewModel.formattedTotalGainLoss, "+50.25")
        XCTAssertEqual(portfolioViewModel.formattedTotalGainLossPercentage, "+5.25%")
        XCTAssertTrue(portfolioViewModel.isPositiveGain)
    }
    
    func testPortfolioViewModelNegativeGain() throws {
        portfolioViewModel.totalGainLoss = -25.75
        portfolioViewModel.totalGainLossPercentage = -2.5
        
        XCTAssertEqual(portfolioViewModel.formattedTotalGainLoss, "-25.75")
        XCTAssertEqual(portfolioViewModel.formattedTotalGainLossPercentage, "-2.50%")
        XCTAssertFalse(portfolioViewModel.isPositiveGain)
    }
}

// MARK: - TradeViewModel Tests
class TradeViewModelTests: XCTestCase {
    var tradeViewModel: TradeViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        tradeViewModel = TradeViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        tradeViewModel = nil
    }
    
    func testTradeViewModelInitialization() throws {
        XCTAssertNotNil(tradeViewModel)
        XCTAssertNil(tradeViewModel.selectedStock)
        XCTAssertEqual(tradeViewModel.tradeType, .buy)
        XCTAssertEqual(tradeViewModel.quantity, "")
        XCTAssertEqual(tradeViewModel.searchQuery, "")
        XCTAssertTrue(tradeViewModel.searchResults.isEmpty)
        XCTAssertEqual(tradeViewModel.currentPrice, 0.0)
        XCTAssertEqual(tradeViewModel.totalCost, 0.0)
        XCTAssertFalse(tradeViewModel.canExecuteTrade)
        XCTAssertEqual(tradeViewModel.availableQuantity, 0)
    }
    
    func testSelectStock() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        
        tradeViewModel.selectStock(stock)
        
        XCTAssertEqual(tradeViewModel.selectedStock?.symbol, "AAPL")
        XCTAssertEqual(tradeViewModel.currentPrice, 174.26)
        XCTAssertTrue(tradeViewModel.hasSelectedStock)
    }
    
    func testCalculateTotalCost() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        tradeViewModel.selectStock(stock)
        
        tradeViewModel.quantity = "2"
        
        // Wait for async calculation
        let expectation = XCTestExpectation(description: "Total cost calculated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.tradeViewModel.totalCost, 348.52)
            XCTAssertEqual(self.tradeViewModel.formattedTotalCost, "$348.52")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTradeButtonTitle() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        tradeViewModel.selectStock(stock)
        
        // Test buy button title
        tradeViewModel.tradeType = .buy
        tradeViewModel.quantity = "5"
        XCTAssertEqual(tradeViewModel.tradeButtonTitle, "Buy 5 Shares")
        
        // Test sell button title
        tradeViewModel.tradeType = .sell
        tradeViewModel.quantity = "3"
        XCTAssertEqual(tradeViewModel.tradeButtonTitle, "Sell 3 Shares")
    }
    
    func testClearSelection() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        tradeViewModel.selectStock(stock)
        tradeViewModel.quantity = "5"
        tradeViewModel.searchQuery = "Apple"
        
        tradeViewModel.clearSelection()
        
        XCTAssertNil(tradeViewModel.selectedStock)
        XCTAssertEqual(tradeViewModel.quantity, "")
        XCTAssertEqual(tradeViewModel.searchQuery, "")
        XCTAssertTrue(tradeViewModel.searchResults.isEmpty)
        XCTAssertEqual(tradeViewModel.currentPrice, 0.0)
        XCTAssertEqual(tradeViewModel.totalCost, 0.0)
        XCTAssertFalse(tradeViewModel.hasSelectedStock)
    }
    
    func testTradeTypeChange() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        tradeViewModel.selectStock(stock)
        
        // Test buy type
        tradeViewModel.tradeType = .buy
        XCTAssertEqual(tradeViewModel.tradeType, .buy)
        
        // Test sell type
        tradeViewModel.tradeType = .sell
        XCTAssertEqual(tradeViewModel.tradeType, .sell)
    }
    
    func testFormattedCurrentPrice() throws {
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        tradeViewModel.selectStock(stock)
        
        XCTAssertEqual(tradeViewModel.formattedCurrentPrice, "$174.26")
    }
    
    func testFormattedAvailableQuantity() throws {
        tradeViewModel.availableQuantity = 10
        XCTAssertEqual(tradeViewModel.formattedAvailableQuantity, "10 shares available")
    }
    
    func testCanSell() throws {
        // Test with no available quantity
        tradeViewModel.availableQuantity = 0
        XCTAssertFalse(tradeViewModel.canSell)
        
        // Test with available quantity
        tradeViewModel.availableQuantity = 5
        XCTAssertTrue(tradeViewModel.canSell)
    }
}

// MARK: - Robustness Tests
class RobustnessTests: XCTestCase {
    var networkManager: NetworkManager!
    var portfolioStore: PortfolioStore!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        networkManager = NetworkManager.shared
        portfolioStore = PortfolioStore.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        networkManager = nil
        portfolioStore = nil
    }
    
    func testNetworkRetryLogic() throws {
        let expectation = XCTestExpectation(description: "Network retry with backoff")
        
        // Simulate network failure
        networkManager.simulateNetworkFailure()
        
        networkManager.fetchAllStocksWithRetry()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("✅ Retry failed as expected: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { stocks in
                    print("✅ Retry succeeded with \(stocks.count) stocks")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testConcurrentPortfolioUpdates() throws {
        let expectation = XCTestExpectation(description: "Concurrent portfolio updates")
        expectation.expectedFulfillmentCount = 10
        
        // Simulate concurrent portfolio updates
        for i in 0..<10 {
            DispatchQueue.global().async {
                let item = PortfolioItem(
                    symbol: "TEST\(i)",
                    quantity: 1,
                    averagePrice: 100.0
                )
                self.portfolioStore.addPortfolioItem(item)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Verify no data corruption
        let portfolioItems = portfolioStore.portfolioItems
        XCTAssertEqual(portfolioItems.count, 10, "Should have 10 portfolio items")
        
        // Verify all items are unique
        let symbols = portfolioItems.map { $0.symbol }
        let uniqueSymbols = Set(symbols)
        XCTAssertEqual(symbols.count, uniqueSymbols.count, "All portfolio items should be unique")
    }
    
    func testInputValidation() throws {
        let tradeViewModel = TradeViewModel()
        
        // Test empty quantity
        tradeViewModel.quantity = ""
        XCTAssertFalse(tradeViewModel.canExecuteTrade)
        
        // Test invalid quantity
        tradeViewModel.quantity = "abc"
        XCTAssertFalse(tradeViewModel.canExecuteTrade)
        XCTAssertNotNil(tradeViewModel.errorMessage)
        
        // Test negative quantity
        tradeViewModel.quantity = "-5"
        XCTAssertFalse(tradeViewModel.canExecuteTrade)
        
        // Test zero quantity
        tradeViewModel.quantity = "0"
        XCTAssertFalse(tradeViewModel.canExecuteTrade)
        
        // Test too large quantity
        tradeViewModel.quantity = "15000"
        XCTAssertFalse(tradeViewModel.canExecuteTrade)
        XCTAssertTrue(tradeViewModel.errorMessage?.contains("10,000") ?? false)
    }
    
    func testOfflineHandling() throws {
        let expectation = XCTestExpectation(description: "Offline handling")
        
        // Simulate offline state
        networkManager.simulateNetworkFailure()
        
        XCTAssertFalse(networkManager.isOnline)
        XCTAssertNotNil(networkManager.lastError)
        
        // Test that we can still access cached data
        let portfolioItems = portfolioStore.portfolioItems
        XCTAssertNotNil(portfolioItems)
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorHandling() throws {
        let tradeViewModel = TradeViewModel()
        let stock = Stock(symbol: "AAPL", name: "Apple Inc.", price: 174.26, dailyChange: -0.42, chartPoints: nil)
        
        tradeViewModel.selectStock(stock)
        tradeViewModel.tradeType = .sell
        tradeViewModel.availableQuantity = 5
        tradeViewModel.quantity = "10" // More than available
        
        // Should show error for insufficient shares
        XCTAssertFalse(tradeViewModel.canExecuteTrade)
        XCTAssertNotNil(tradeViewModel.errorMessage)
        XCTAssertTrue(tradeViewModel.errorMessage?.contains("Insufficient shares") ?? false)
    }
    
    func testDataConsistency() throws {
        let expectation = XCTestExpectation(description: "Data consistency test")
        
        // Add multiple items for the same stock
        let item1 = PortfolioItem(symbol: "AAPL", quantity: 2, averagePrice: 150.0)
        let item2 = PortfolioItem(symbol: "AAPL", quantity: 3, averagePrice: 160.0)
        
        portfolioStore.addPortfolioItem(item1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.portfolioStore.addPortfolioItem(item2)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let items = self.portfolioStore.portfolioItems
                let aaplItem = items.first { $0.symbol == "AAPL" }
                
                XCTAssertNotNil(aaplItem)
                XCTAssertEqual(aaplItem?.quantity, 5) // 2 + 3
                
                // Verify average price calculation
                let expectedAverage = ((2 * 150.0) + (3 * 160.0)) / 5.0
                XCTAssertEqual(aaplItem?.averagePrice, expectedAverage, accuracy: 0.01)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - UI Component Tests
class UIComponentTests: XCTestCase {
    
    func testTransactionModel() throws {
        let transaction = Transaction(
            symbol: "AAPL",
            quantity: 5,
            price: 174.26,
            type: .buy
        )
        
        XCTAssertEqual(transaction.symbol, "AAPL")
        XCTAssertEqual(transaction.quantity, 5)
        XCTAssertEqual(transaction.price, 174.26)
        XCTAssertEqual(transaction.type, .buy)
        XCTAssertEqual(transaction.totalValue, 871.30)
        XCTAssertEqual(transaction.formattedTotalValue, "$871.30")
    }
    
    func testTransactionTypes() throws {
        XCTAssertEqual(TransactionType.buy.rawValue, "BUY")
        XCTAssertEqual(TransactionType.sell.rawValue, "SELL")
        XCTAssertEqual(TransactionType.allCases.count, 2)
    }
    
    func testStockChartDataGeneration() throws {
        let basePrice = 100.0
        let change = 5.0
        let volatility = abs(change) * 0.5
        
        let chartPoints = (0..<5).map { index in
            let progress = Double(index) / 4.0
            let randomVariation = (Double.random(in: -1...1) * volatility)
            return basePrice - (change * progress) + randomVariation
        }
        
        XCTAssertEqual(chartPoints.count, 5)
        XCTAssertTrue(chartPoints.allSatisfy { $0 > 0 })
    }
    
    func testPortfolioStockChartIntegration() throws {
        let portfolioStock = PortfolioStock(
            symbol: "AAPL",
            name: "Apple Inc.",
            currentPrice: 174.26,
            quantity: 2,
            averagePrice: 150.0,
            dailyChange: -0.42,
            totalValue: 348.52,
            gainLoss: 48.52,
            gainLossPercentage: 16.17
        )
        
        // Test chart data generation
        let basePrice = portfolioStock.currentPrice
        let change = portfolioStock.dailyChange
        let volatility = abs(change) * 0.5
        
        let chartPoints = (0..<5).map { index in
            let progress = Double(index) / 4.0
            return basePrice - (change * progress)
        }
        
        XCTAssertEqual(chartPoints.count, 5)
        XCTAssertEqual(chartPoints.first, 174.26)
        XCTAssertEqual(chartPoints.last, 174.68, accuracy: 0.01)
    }
}
