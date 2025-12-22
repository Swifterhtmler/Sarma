//
//  UserProfile.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//
//

// Models/UserProfile.swift
import SwiftData
import Foundation

@Model
final class UserProfile {
    var serviceStartDate: Date?
    var serviceEndDate: Date?
    var garrison: String?
    
    init(serviceStartDate: Date? = nil, serviceEndDate: Date? = nil, garrison: String? = nil) {
        self.serviceStartDate = serviceStartDate
        self.serviceEndDate = serviceEndDate
        self.garrison = garrison
    }
}
