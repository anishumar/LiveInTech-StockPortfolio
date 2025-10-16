//
//  User.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let password: String
    var firstName: String
    var lastName: String
    let createdAt: Date
    
    init(email: String, password: String, firstName: String, lastName: String) {
        self.id = UUID()
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = Date()
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
