//
//  BudgetEntry.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//

// Models/BudgetEntry.swift
import SwiftData
import Foundation

@Model  
final class BudgetEntry {
    var date: Date
    var amount: Double
    var category: String
    var notes: String?
    
    init(date: Date, amount: Double, category: String, notes: String? = nil) {
        self.date = date
        self.amount = amount
        self.category = category
        self.notes = notes
    }
}
