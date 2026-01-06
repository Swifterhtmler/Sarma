//
//  SharedDataManager.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 6.1.2026.
//


// Shared/SharedDataManager.swift
import Foundation

struct ServiceData: Codable {
    let serviceEndDate: Date?
    let garrison: String?
}

class SharedDataManager {
    static let shared = SharedDataManager()
    
    private let appGroupID = "group.com.palvelus.palveluspolku"
    private let serviceDataKey = "serviceData"
    private let isPremiumKey = "isPremium"  // ← NEW
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    // Save data from main app
    func saveServiceData(endDate: Date?, garrison: String?) {
        let data = ServiceData(serviceEndDate: endDate, garrison: garrison)
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults?.set(encoded, forKey: serviceDataKey)
        }
    }
    
    // Load data in widget
    func loadServiceData() -> ServiceData? {
        guard let data = userDefaults?.data(forKey: serviceDataKey),
              let decoded = try? JSONDecoder().decode(ServiceData.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    // Calculate days remaining
    func daysRemaining(until endDate: Date) -> Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: now, to: end)
        return components.day ?? 0
    }
    
    // ← NEW: Premium status management
    func setIsPremium(_ isPremium: Bool) {
        userDefaults?.set(isPremium, forKey: isPremiumKey)
    }
    
    func isPremium() -> Bool {
        return userDefaults?.bool(forKey: isPremiumKey) ?? false
    }
}
