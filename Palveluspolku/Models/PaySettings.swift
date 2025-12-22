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
    var dailyRate: Double  // This is now ignored - we calculate based on days
    var startDate: Date
    var isWoman: Bool      // For the 1.50€ varusraha
    
    init(dailyRate: Double = 6.10, startDate: Date = Date(), isWoman: Bool = false) {
        self.dailyRate = dailyRate
        self.startDate = startDate
        self.isWoman = isWoman
    }
    
    // Calculate correct daily rate based on days served
    func getDailyRate(for daysServed: Int) -> Double {
        let baseRate: Double
        
        if daysServed <= 165 {
            baseRate = 6.10
        } else if daysServed <= 255 {
            baseRate = 10.15
        } else {
            baseRate = 14.15
        }
        
        // Add varusraha for women
        let varusraha = isWoman ? 1.50 : 0.0
        
        return baseRate + varusraha
    }
    
    // Computed: Total earned so far
    var totalEarned: Double {
        let daysServed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        
        if daysServed <= 0 {
            return 0.0
        }
        
        var total = 0.0
        
        // Calculate tier by tier
        if daysServed <= 165 {
            // All days at tier 1
            total = Double(daysServed) * getDailyRate(for: 1)
        } else if daysServed <= 255 {
            // First 165 days at tier 1, rest at tier 2
            total = Double(165) * getDailyRate(for: 165)
            total += Double(daysServed - 165) * getDailyRate(for: 166)
        } else {
            // First 165 at tier 1, next 90 at tier 2, rest at tier 3
            total = Double(165) * getDailyRate(for: 165)
            total += Double(90) * getDailyRate(for: 166)  // 166-255 = 90 days
            total += Double(daysServed - 255) * getDailyRate(for: 256)
        }
        
        return total
    }
    
    // Current daily rate (what they're earning today)
    var currentDailyRate: Double {
        let daysServed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return getDailyRate(for: daysServed)
    }
    
    // Computed: Expected next payment (twice per month on Fridays)
    var nextPaymentDate: Date {
        let today = Date()
        let calendar = Calendar.current
        
        // Find next Friday
        var nextFriday = today
        while calendar.component(.weekday, from: nextFriday) != 6 { // 6 = Friday
            nextFriday = calendar.date(byAdding: .day, value: 1, to: nextFriday)!
        }
        
        return nextFriday
    }
    
    // Computed: Days since last payment (estimate - twice per month)
    var daysSinceLastPayment: Int {
        // Rough estimate: payments every ~15 days
        let today = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: today)
        
        if currentDay <= 15 {
            return currentDay
        } else {
            return currentDay - 15
        }
    }
    
    // Computed: Expected next payment amount
    var nextPaymentAmount: Double {
        return Double(daysSinceLastPayment) * currentDailyRate
    }
}
