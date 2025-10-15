//
//  ErrorAlertView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct ErrorAlertView: View {
    let error: Error
    let onRetry: (() -> Void)?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Error Icon
            Image(systemName: errorIcon)
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            // Error Title
            Text(errorTitle)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Error Message
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: 12) {
                if onRetry != nil {
                    Button("Retry") {
                        onRetry?()
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Dismiss") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
    
    private var errorIcon: String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .networkError, .timeout:
                return "wifi.slash"
            case .serverError:
                return "exclamationmark.triangle"
            case .decodingError:
                return "doc.badge.gearshape"
            case .noData:
                return "doc.text"
            default:
                return "exclamationmark.circle"
            }
        }
        return "exclamationmark.circle"
    }
    
    private var errorTitle: String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .networkError:
                return "Network Error"
            case .timeout:
                return "Request Timeout"
            case .serverError:
                return "Server Error"
            case .decodingError:
                return "Data Error"
            case .noData:
                return "No Data"
            default:
                return "Unknown Error"
            }
        }
        return "Error"
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        
        ErrorAlertView(
            error: NetworkError.networkError("Connection failed"),
            onRetry: { print("Retry tapped") },
            onDismiss: { print("Dismiss tapped") }
        )
        .padding()
    }
}
