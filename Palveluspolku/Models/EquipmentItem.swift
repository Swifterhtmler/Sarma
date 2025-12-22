//
//  inventoryItem.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 20.12.2025.
//

import SwiftData
import Foundation


@Model
final class EquipmentItem {
    var name: String
    var category: String
    var serialNumber: String?
    var isIssued: Bool
    var isReturned: Bool
    var issueDate: Date?
    var returnDate: Date?
    var notes: String?
    
    init(
        name: String,
        category: String,
        serialNumber: String? = nil,
        isIssued: Bool = false,
        isReturned: Bool = false,
        issueDate: Date? = nil,
        returnDate: Date? = nil,
        notes: String? = nil
    ) {
        self.name = name
        self.category = category
        self.serialNumber = serialNumber
        self.isIssued = isIssued
        self.isReturned = isReturned
        self.issueDate = issueDate
        self.returnDate = returnDate
        self.notes = notes
    }
}
