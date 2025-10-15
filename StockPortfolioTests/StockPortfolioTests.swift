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
