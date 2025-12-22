//
//  CooperTest.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//

import SwiftData
import Foundation

@Model  // ← THIS is required!
final class CooperTest {
    var date: Date
    var distance: Int
    var notes: String?
    
    init(date: Date, distance: Int, notes: String? = nil) {
        self.date = date
        self.distance = distance
        self.notes = notes
    }
}
