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
    
    // Helper computed property
    var varuskunta: Varuskunta? {
            guard let slug = garrison else { return nil }
            return Varuskunta.all.first(where: { $0.slug == slug })
    }
    
    
    init(serviceStartDate: Date? = nil, serviceEndDate: Date? = nil, garrison: String? = nil) {
        self.serviceStartDate = serviceStartDate
        self.serviceEndDate = serviceEndDate
        self.garrison = garrison
    }
}
