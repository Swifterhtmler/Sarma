//
//  PaySettings.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//

// Models/PaySettings.swift

import SwiftData
import Foundation

@Model
final class PaySettings {
    var isWoman: Bool
    
    init(isWoman: Bool = false) {
        self.isWoman = isWoman
    }

    func getDailyRate(for daysServed: Int) -> Double {
        let baseRate: Double
        
        if daysServed <= 165 {
            baseRate = 6.10
        } else if daysServed <= 255 {
            baseRate = 10.15
        } else {
            baseRate = 14.15
        }
        
        let varusraha = isWoman ? 1.50 : 0.0
        return baseRate + varusraha
    }
    
    // Calculate total earned (pass in start date from UserProfile)
    func totalEarned(serviceStartDate: Date?) -> Double {
        guard let startDate = serviceStartDate else { return 0.0 }
        
        let daysServed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        
        if daysServed <= 0 {
            return 0.0
        }
        
        var total = 0.0
        
        if daysServed <= 165 {
            total = Double(daysServed) * getDailyRate(for: 1)
        } else if daysServed <= 255 {
            total = Double(165) * getDailyRate(for: 165)
            total += Double(daysServed - 165) * getDailyRate(for: 166)
        } else {
            total = Double(165) * getDailyRate(for: 165)
            total += Double(90) * getDailyRate(for: 166)
            total += Double(daysServed - 255) * getDailyRate(for: 256)
        }
        
        return total
    }
    
    // Current daily rate (pass in days served)
    func currentDailyRate(daysServed: Int) -> Double {
        return getDailyRate(for: max(0, daysServed))
    }
    
    // Next payment date (independent of service dates)
    func nextPaymentDate() -> Date {
        let today = Date()
        let calendar = Calendar.current
        
        var nextFriday = today
        while calendar.component(.weekday, from: nextFriday) != 6 {
            nextFriday = calendar.date(byAdding: .day, value: 1, to: nextFriday)!
        }
        
        return nextFriday
    }
    
    // Days since last payment
    func daysSinceLastPayment() -> Int {
        let today = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: today)
        
        if currentDay <= 15 {
            return currentDay
        } else {
            return currentDay - 15
        }
    }
    
    // Next payment amount (pass in current daily rate)
    func nextPaymentAmount(currentRate: Double) -> Double {
        return Double(daysSinceLastPayment()) * currentRate
    }
}
