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
    @State private var showPaywall = false

    
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
                    .onOpenURL { url in
                                            // Handle widget tap - only show paywall if not premium
                                            if url.absoluteString == "palveluspolku://premium" {
                                                if !SharedDataManager.shared.isPremium() {
                                                    showPaywall = true
                                                }
                                                // If already premium, do nothing (widget works normally)
                                            }
                                        }
                                        .sheet(isPresented: $showPaywall) {
                                            PaywallView()
                                        }
                
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .modelContainer(for: [UserProfile.self])
                
              }
        }
        .environment(\.locale, Locale(identifier: "fi_FI"))

    }
}
