//
//  AuthViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class AuthViewModel: BaseViewModel {
    @Published var isLoggedIn = false
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    
    private let userSession = UserSession.shared
    private let userStore = UserStore.shared
    
    override init() {
        super.init()
        
        // Listen to user session changes
        userSession.$isLoggedIn
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)
    }
    
    func login(email: String, password: String) {
        clearErrors()
        
        // Validate inputs
        guard validateEmail(email) else {
            emailError = "Please enter a valid email address"
            return
        }
        
        guard validatePassword(password) else {
            passwordError = "Password must be at least 8 characters long"
            return
        }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.performLogin(email: email, password: password)
        }
    }
    
    func signup(firstName: String, lastName: String, email: String, password: String, confirmPassword: String) {
        clearErrors()
        
        // Validate inputs
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            emailError = "Please enter your first name"
            return
        }
        
        guard !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            emailError = "Please enter your last name"
            return
        }
        
        guard validateEmail(email) else {
            emailError = "Please enter a valid email address"
            return
        }
        
        guard validatePassword(password) else {
            passwordError = "Password must be at least 8 characters long"
            return
        }
        
        guard validateConfirmPassword(password: password, confirmPassword: confirmPassword) else {
            confirmPasswordError = "Passwords do not match"
            return
        }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.performSignup(firstName: firstName, lastName: lastName, email: email, password: password)
        }
    }
    
    private func performLogin(email: String, password: String) {
        // Check if user exists and password matches
        if let user = userStore.getUser(email: email) {
            if user.password == password {
                userSession.login(user: user)
                isLoading = false
            } else {
                errorMessage = "Invalid email or password"
                isLoading = false
            }
        } else {
            errorMessage = "No account found with this email"
            isLoading = false
        }
    }
    
    private func performSignup(firstName: String, lastName: String, email: String, password: String) {
        // Check if user already exists
        if userStore.getUser(email: email) != nil {
            errorMessage = "An account with this email already exists"
            isLoading = false
            return
        }
        
        // Create new user
        let newUser = User(email: email, password: password, firstName: firstName, lastName: lastName)
        userStore.saveUser(newUser)
        userSession.login(user: newUser)
        isLoading = false
    }
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= 8
    }
    
    func validateConfirmPassword(password: String, confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
    
    private func clearErrors() {
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        errorMessage = nil
    }
}
