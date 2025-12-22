//
//  LeaveDay.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//

// Models/LeaveDay.swift
import SwiftData
import Foundation

@Model
final class LeaveDay {
    var date: Date
    var leaveType: String  // "Weekend", "Regular", "Special"
    var approved: Bool
    var notes: String?
    
    init(date: Date, leaveType: String = "Regular", approved: Bool = false, notes: String? = nil) {
        self.date = date
        self.leaveType = leaveType
        self.approved = approved
        self.notes = notes
    }
}
