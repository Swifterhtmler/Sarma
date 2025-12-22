//
//  PackingItem.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 19.12.2025.
//

// Models/PackingItem.swift
import SwiftData
import Foundation

@Model
final class PackingItem {
    var name: String
    var category: String
    var isChecked: Bool
    var isCustom: Bool  
    
    init(name: String, category: String, isChecked: Bool = false, isCustom: Bool = false) {
        self.name = name
        self.category = category
        self.isChecked = isChecked
        self.isCustom = isCustom
    }
}
