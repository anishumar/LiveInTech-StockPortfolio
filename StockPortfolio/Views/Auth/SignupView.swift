//
//  SignupView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(Color.blue)
                    
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Join StockPort and start building your portfolio")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 16) {
                    // First Name Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your first name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                    
                    // Last Name Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your last name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        if let emailError = viewModel.emailError {
                            Text(emailError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let passwordError = viewModel.passwordError {
                            Text(passwordError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Confirm Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let confirmPasswordError = viewModel.confirmPasswordError {
                            Text(confirmPasswordError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Sign Up Button
                    Button(action: {
                        viewModel.signup(firstName: firstName, lastName: lastName, email: email, password: password, confirmPassword: confirmPassword)
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(viewModel.isLoading || firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                    
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Login Link
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                    
                    Button("Sign In") {
                        dismiss()
                    }
                    .foregroundColor(Color.blue)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
                if isLoggedIn {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    SignupView()
}
