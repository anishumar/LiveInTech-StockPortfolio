//
//  ExportView.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import SwiftUI

struct ExportView: View {
    @StateObject private var viewModel = ExportViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var exportText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Export Options
                exportOptionsSection
                
                // Export Preview
                if viewModel.isExporting {
                    exportProgressView
                } else if let _ = viewModel.exportData {
                    exportPreviewSection
                } else {
                    generateExportSection
                }
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [exportText])
            }
        }
    }
    
    // MARK: - Export Options Section
    
    private var exportOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Export Options")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Format Selection
                HStack {
                    Text("Format")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Picker("Format", selection: $viewModel.exportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                }
                
                // Date Range
                HStack {
                    Text("Date Range")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Picker("Date Range", selection: $viewModel.dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Include Options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Include")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Toggle("Transactions", isOn: $viewModel.includeTransactions)
                    Toggle("Watchlist", isOn: $viewModel.includeWatchlist)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Generate Export Section
    
    private var generateExportSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 50))
                .foregroundColor(Color.blue)
            
            Text("Generate Export")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Generate your portfolio data for export in the selected format.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Generate Export") {
                viewModel.generateExportData()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Export Progress View
    
    private var exportProgressView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Generating export...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Export Preview Section
    
    private var exportPreviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Export Preview")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.exportData?.portfolio.count ?? 0) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Export Summary
            exportSummary
            
            // Export Actions
            exportActions
        }
    }
    
    private var exportSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Portfolio Holdings")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(viewModel.exportData?.portfolio.count ?? 0)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.includeTransactions {
                HStack {
                    Text("Transactions")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(viewModel.exportData?.transactions.count ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if viewModel.includeWatchlist {
                HStack {
                    Text("Watchlist")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(viewModel.exportData?.watchlist.count ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    private var exportActions: some View {
        VStack(spacing: 12) {
            Button(action: {
                exportText = viewModel.exportFormat == .csv ? viewModel.exportToCSV() : viewModel.exportToJSON()
                showingShareSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Export")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                viewModel.generateExportData()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Regenerate")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
}
