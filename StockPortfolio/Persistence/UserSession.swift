//
//  UserSession.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine

class UserSession: ObservableObject {
    static let shared = UserSession()
    
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"
    private let isLoggedInKey = "isLoggedIn"
    
    private init() {
        loadSession()
    }
    
    func login(user: User) {
        currentUser = user
        isLoggedIn = true
        saveSession()
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        clearSession()
    }
    
    func updateCurrentUser(_ user: User) {
        currentUser = user
        saveSession()
    }
    
    private func saveSession() {
        if let user = currentUser {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(user) {
                userDefaults.set(encoded, forKey: userKey)
            }
        }
        userDefaults.set(isLoggedIn, forKey: isLoggedInKey)
    }
    
    private func loadSession() {
        isLoggedIn = userDefaults.bool(forKey: isLoggedInKey)
        
        if let data = userDefaults.data(forKey: userKey) {
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(User.self, from: data) {
                currentUser = user
            }
        }
    }
    
    private func clearSession() {
        userDefaults.removeObject(forKey: userKey)
        userDefaults.removeObject(forKey: isLoggedInKey)
    }
}
