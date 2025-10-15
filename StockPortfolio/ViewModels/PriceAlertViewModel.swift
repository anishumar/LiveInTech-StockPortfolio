//
//  PriceAlertViewModel.swift
//  StockPortfolio
//
//  Created by Anish Umar on 15/10/25.
//

import Foundation
import Combine
import UserNotifications

class PriceAlertViewModel: BaseViewModel {
    // MARK: - Published Properties
    
    @Published var priceAlerts: [PriceAlert] = []
    @Published var triggeredAlerts: [PriceAlert] = []
    @Published var showingCreateAlert = false
    @Published var selectedStock: Stock?
    @Published var targetPrice: String = ""
    @Published var selectedCondition: AlertCondition = .above
    @Published var notificationEnabled: Bool = true
    
    // MARK: - Dependencies
    
    private let userDefaults = UserDefaults.standard
    private let networkManager = NetworkManager.shared
    private let alertKey = "priceAlerts"
    private let triggeredAlertsKey = "triggeredAlerts"
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        loadAlerts()
        setupPriceMonitoring()
        requestNotificationPermission()
    }
    
    // MARK: - Setup
    
    private func setupPriceMonitoring() {
        // Monitor stock prices for alert triggers
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAlerts()
            }
            .store(in: &cancellables)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    
    func createAlert(for stock: Stock) {
        selectedStock = stock
        targetPrice = String(format: "%.2f", stock.price)
        showingCreateAlert = true
    }
    
    func saveAlert() {
        guard let stock = selectedStock,
              let price = Double(targetPrice),
              price > 0 else {
            return
        }
        
        let alert = PriceAlert(
            symbol: stock.symbol,
            stockName: stock.name,
            targetPrice: price,
            condition: selectedCondition,
            isEnabled: true,
            notificationEnabled: notificationEnabled
        )
        
        priceAlerts.append(alert)
        saveAlerts()
        
        // Reset form
        selectedStock = nil
        targetPrice = ""
        selectedCondition = .above
        notificationEnabled = true
        showingCreateAlert = false
    }
    
    func deleteAlert(_ alert: PriceAlert) {
        priceAlerts.removeAll { $0.id == alert.id }
        saveAlerts()
    }
    
    func toggleAlert(_ alert: PriceAlert) {
        if let index = priceAlerts.firstIndex(where: { $0.id == alert.id }) {
            let updatedAlert = PriceAlert(
                symbol: alert.symbol,
                stockName: alert.stockName,
                targetPrice: alert.targetPrice,
                condition: alert.condition,
                isEnabled: !alert.isEnabled,
                notificationEnabled: alert.notificationEnabled
            )
            priceAlerts[index] = updatedAlert
            saveAlerts()
        }
    }
    
    func clearTriggeredAlerts() {
        triggeredAlerts.removeAll()
        saveTriggeredAlerts()
    }
    
    func dismissAlert(_ alert: PriceAlert) {
        triggeredAlerts.removeAll { $0.id == alert.id }
        saveTriggeredAlerts()
    }
    
    // MARK: - Private Methods
    
    private func loadAlerts() {
        // Load active alerts
        if let data = userDefaults.data(forKey: alertKey),
           let alerts = try? JSONDecoder().decode([PriceAlert].self, from: data) {
            priceAlerts = alerts
        }
        
        // Load triggered alerts
        if let data = userDefaults.data(forKey: triggeredAlertsKey),
           let alerts = try? JSONDecoder().decode([PriceAlert].self, from: data) {
            triggeredAlerts = alerts
        }
    }
    
    private func saveAlerts() {
        if let data = try? JSONEncoder().encode(priceAlerts) {
            userDefaults.set(data, forKey: alertKey)
        }
    }
    
    private func saveTriggeredAlerts() {
        if let data = try? JSONEncoder().encode(triggeredAlerts) {
            userDefaults.set(data, forKey: triggeredAlertsKey)
        }
    }
    
    private func checkAlerts() {
        guard !priceAlerts.isEmpty else { return }
        
        for alert in priceAlerts {
            guard alert.isActive else { continue }
            
            // Get current price for the stock
            if let stock = Stock.mockStocks.first(where: { $0.symbol == alert.symbol }) {
                if alert.checkTrigger(currentPrice: stock.price) {
                    triggerAlert(alert, currentPrice: stock.price)
                }
            }
        }
    }
    
    private func triggerAlert(_ alert: PriceAlert, currentPrice: Double) {
        // Move alert to triggered list
        priceAlerts.removeAll { $0.id == alert.id }
        
        let triggeredAlert = PriceAlert(
            symbol: alert.symbol,
            stockName: alert.stockName,
            targetPrice: alert.targetPrice,
            condition: alert.condition,
            isEnabled: false,
            notificationEnabled: alert.notificationEnabled
        )
        
        triggeredAlerts.append(triggeredAlert)
        
        // Save changes
        saveAlerts()
        saveTriggeredAlerts()
        
        // Send notification if enabled
        if alert.notificationEnabled {
            sendNotification(for: triggeredAlert, currentPrice: currentPrice)
        }
    }
    
    private func sendNotification(for alert: PriceAlert, currentPrice: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Price Alert Triggered"
        content.body = "\(alert.symbol) is now \(String(format: "$%.2f", currentPrice))"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var activeAlertsCount: Int {
        return priceAlerts.filter { $0.isActive }.count
    }
    
    var triggeredAlertsCount: Int {
        return triggeredAlerts.count
    }
    
    var hasAlerts: Bool {
        return !priceAlerts.isEmpty || !triggeredAlerts.isEmpty
    }
    
    var canCreateAlert: Bool {
        return selectedStock != nil && !targetPrice.isEmpty && Double(targetPrice) != nil
    }
}
