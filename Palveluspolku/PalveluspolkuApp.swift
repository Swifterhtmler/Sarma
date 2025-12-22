//
//  PalveluspolkuApp.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

import SwiftUI
import SwiftData

@main
struct PalveluspolkuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            UserProfile.self,
            CooperTest.self,
            BudgetEntry.self,
            PaySettings.self,
            LeaveDay.self,
            PackingItem.self,
            PreparationItem.self,
            EquipmentItem.self
        ])
    }
}
