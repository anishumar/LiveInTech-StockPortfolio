//
//  StockPortfolioUITests.swift
//  StockPortfolioUITests
//
//  Created by Anish Umar on 15/10/25.
//

import XCTest

final class StockPortfolioUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

// MARK: - Authentication UI Tests
extension StockPortfolioUITests {
    
    func testLoginFlow() throws {
        // Test login with valid credentials
        let emailField = app.textFields["Enter your email"]
        let passwordField = app.secureTextFields["Enter your password"]
        let signInButton = app.buttons["Sign In"]
        
        XCTAssertTrue(emailField.exists)
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(signInButton.exists)
        
        // Enter test credentials
        emailField.tap()
        emailField.typeText("test@stockport.com")
        
        passwordField.tap()
        passwordField.typeText("Test@123")
        
        // Tap sign in button
        signInButton.tap()
        
        // Wait for navigation to home view
        let welcomeText = app.staticTexts["Welcome to StockPort!"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5))
    }
    
    func testSignupFlow() throws {
        // Test signup flow
        let signUpButton = app.buttons["Sign Up"]
        XCTAssertTrue(signUpButton.exists)
        
        signUpButton.tap()
        
        // Verify signup view appears
        let createAccountText = app.staticTexts["Create Account"]
        XCTAssertTrue(createAccountText.waitForExistence(timeout: 2))
        
        // Fill signup form
        let emailField = app.textFields["Enter your email"]
        let passwordField = app.secureTextFields["Enter your password"]
        let confirmPasswordField = app.secureTextFields["Confirm your password"]
        
        emailField.tap()
        emailField.typeText("newuser@example.com")
        
        passwordField.tap()
        passwordField.typeText("NewPassword123")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("NewPassword123")
        
        // Tap create account button
        let createAccountButton = app.buttons["Create Account"]
        createAccountButton.tap()
        
        // Wait for navigation to home view
        let welcomeText = app.staticTexts["Welcome to StockPort!"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5))
    }
    
    func testInvalidEmailValidation() throws {
        let emailField = app.textFields["Enter your email"]
        let passwordField = app.secureTextFields["Enter your password"]
        let signInButton = app.buttons["Sign In"]
        
        // Enter invalid email
        emailField.tap()
        emailField.typeText("invalid-email")
        
        passwordField.tap()
        passwordField.typeText("Test@123")
        
        signInButton.tap()
        
        // Check for email validation error
        let errorText = app.staticTexts["Please enter a valid email address"]
        XCTAssertTrue(errorText.waitForExistence(timeout: 2))
    }
    
    func testShortPasswordValidation() throws {
        let emailField = app.textFields["Enter your email"]
        let passwordField = app.secureTextFields["Enter your password"]
        let signInButton = app.buttons["Sign In"]
        
        // Enter valid email but short password
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("short")
        
        signInButton.tap()
        
        // Check for password validation error
        let errorText = app.staticTexts["Password must be at least 8 characters long"]
        XCTAssertTrue(errorText.waitForExistence(timeout: 2))
    }
}
