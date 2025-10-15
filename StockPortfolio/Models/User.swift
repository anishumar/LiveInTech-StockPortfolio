//
//  User.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id = UUID()
    let email: String
    let password: String
    let createdAt: Date
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        self.createdAt = Date()
    }
}
