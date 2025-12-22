//
//  StorageItem.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

import SwiftData
import Foundation

@Model
final class StorageItem {
    @Attribute(.unique) var key: String
    var value: String
    var updatedAt: Date
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
        self.updatedAt = Date()
    }
}
