//
//  PreparationItem.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 19.12.2025.
//

// Models/PreparationItem.swift
import SwiftData
import Foundation

@Model
final class PreparationItem {
    var title: String
    var category: String
    var isCompleted: Bool
    var isCustom: Bool
    var dueWeeksBefore: Int?
    
    init(title: String, category: String, isCompleted: Bool = false, isCustom: Bool = false, dueWeeksBefore: Int? = nil) {
        self.title = title
        self.category = category
        self.isCompleted = isCompleted
        self.isCustom = isCustom
        self.dueWeeksBefore = dueWeeksBefore
    }
}
