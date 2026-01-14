//
//  SharedDataManager.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 6.1.2026.
//

// Shared/SharedDataManager.swift
import Foundation

struct ServiceData: Codable {
    let serviceStartDate: Date?  
    let serviceEndDate: Date?
    let garrison: String?
}

class SharedDataManager {
    static let shared = SharedDataManager()
    
    private let appGroupID = "group.com.palvelus.palveluspolku"
    private let serviceDataKey = "serviceData"
    private let isPremiumKey = "isPremium"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    // Save data from main app
    func saveServiceData(startDate: Date?, endDate: Date?, garrison: String?) {  // ← UPDATED
        let data = ServiceData(
            serviceStartDate: startDate,  // ← ADDED
            serviceEndDate: endDate,
            garrison: garrison
        )
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
    
    func setIsPremium(_ isPremium: Bool) {
        userDefaults?.set(isPremium, forKey: isPremiumKey)
    }
    
    func isPremium() -> Bool {
        return userDefaults?.bool(forKey: isPremiumKey) ?? false
    }
    
    // for new large widget
    
    private let menuDataKey = "todaysMenu"

    func saveTodaysMenu(_ menuText: String) {
        userDefaults?.set(menuText, forKey: menuDataKey)
    }

    func loadTodaysMenu() -> String? {
        return userDefaults?.string(forKey: menuDataKey)
    }
}
