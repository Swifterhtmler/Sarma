//
//  PalveluspolkuApp.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

// PalveluspolkuApp.swift
import SwiftUI
import SwiftData
import WidgetKit
import RevenueCat

@main
struct PalveluspolkuApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showPaywall = false
    
    init() {
        // Configure RevenueCat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_BKUQybrKGSUIMrzddytdPsSOlRm")
        
        // Check subscription status on launch
        checkSubscriptionStatus()
    }

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
                        if url.absoluteString == "palveluspolku://premium" {
                            if !SharedDataManager.shared.isPremium() {
                                showPaywall = true
                            }
                        }
                    }
                    .sheet(isPresented: $showPaywall) {
                        RevenueCatPaywallView()
                    }
                    .onAppear {
                        checkSubscriptionStatus()
                    }
                
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .modelContainer(for: [UserProfile.self])
            }
        }
        .environment(\.locale, Locale(identifier: "fi_FI"))
    }
    
    func checkSubscriptionStatus() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                let isPremium = customerInfo.entitlements["Särmä Pro"]?.isActive == true
                
                SharedDataManager.shared.setIsPremium(isPremium)
                WidgetCenter.shared.reloadAllTimelines()
                
                print("✅ Premium status: \(isPremium)")
            } catch {
                print("❌ RevenueCat error: \(error)")
                // Don't block app if RevenueCat fails
            }
        }
    }
}
