//
//  EditProfileView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var userSession = UserSession.shared
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your first name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your last name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                } header: {
                    Text("Profile Information")
                } footer: {
                    Text("Your email is used for account identification and cannot be changed.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateUserProfile(firstName: firstName, lastName: lastName, email: email)
                        dismiss()
                    }
                    .disabled(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let user = userSession.currentUser {
                firstName = user.firstName
                lastName = user.lastName
                email = user.email
            }
        }
    }
}
