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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    

    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
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
                
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .modelContainer(for: [UserProfile.self])
                
              }
        }
        .environment(\.locale, Locale(identifier: "fi_FI"))

    }
}
