//
//  UserStore.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

class UserStore {
    static let shared = UserStore()
    
    private let userDefaults = UserDefaults.standard
    private let usersKey = "storedUsers"
    
    private init() {
        seedTestUser()
    }
    
    func saveUser(_ user: User) {
        var users = getAllUsers()
        users.append(user)
        saveUsers(users)
    }
    
    func getUser(email: String) -> User? {
        let users = getAllUsers()
        return users.first { $0.email == email }
    }
    
    func getAllUsers() -> [User] {
        guard let data = userDefaults.data(forKey: usersKey) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([User].self, from: data)) ?? []
    }
    
    private func saveUsers(_ users: [User]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(users) {
            userDefaults.set(encoded, forKey: usersKey)
        }
    }
    
    private func seedTestUser() {
        // Only seed if no users exist
        if getAllUsers().isEmpty {
            let testUser = User(email: "test@stockport.com", password: "Test@123", firstName: "Test", lastName: "User")
            saveUser(testUser)
        }
    }
    
    func updateUser(_ user: User) {
        var users = getAllUsers()
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            saveUsers(users)
        }
    }
}
