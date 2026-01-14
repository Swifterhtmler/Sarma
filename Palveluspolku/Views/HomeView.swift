//
//  HomeView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

// Views/HomeView.swift
import SwiftUI
import SwiftData
import StoreKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var hasCheckedReviewPrompt = false
    
    @State private var trigger: Int = 0
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var totalDays: Int {
        guard let profile = profile,
              let startDate = profile.serviceStartDate,
              let endDate = profile.serviceEndDate else {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    private var daysServed: Int {
        guard let profile = profile,
              let startDate = profile.serviceStartDate else {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }
    
    private var hasServiceStarted: Bool {
        guard let profile = profile,
              let startDate = profile.serviceStartDate else {
            return false
        }
        return Date() >= startDate
    }

    private var hasServiceEnded: Bool {
        guard let profile = profile,
              let endDate = profile.serviceEndDate else {
            return false
        }
        return Calendar.current.isDateInToday(endDate) || Date() > endDate
    }

    private var isServiceEndingToday: Bool {
        guard let profile = profile,
              let endDate = profile.serviceEndDate else {
            return false
        }
        return Calendar.current.isDateInToday(endDate)
    }
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Big countdown card
                    CountdownCard(profile: profile)
                    
                    // Quick actions
                    QuickActionsSection(profile: profile)
                    
                    if !hasServiceEnded {
                        AllFeaturesSection()
                    } else {
                        Text("Palvelus suoritettu 🎉")
                            .foregroundStyle(Color(.green))
                                 .fontWeight(.bold)
                                 .frame(maxWidth: .infinity, alignment: .center)
                                 .padding()
                                 .background(Color(.systemBackground))
                                 .cornerRadius(12)
                                 .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                                 
                    }
                    
                }
                .padding()
            }
            .navigationTitle("Särmä")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .onAppear {
                if !hasCheckedReviewPrompt {
                    checkForReviewPrompt()
                    hasCheckedReviewPrompt = true
                }
            }
        }
    }
    
    private func checkForReviewPrompt() {
        guard let profile = profile,
              let serviceEndDate = profile.serviceEndDate else {
            return
        }
        
        let now = Date()
        let daysUntilEnd = Calendar.current.dateComponents([.day], from: now, to: serviceEndDate).day ?? 0
        
        // Check for milestone days remaining
        let milestone: Int?
        switch daysUntilEnd {
        case 150:
            milestone = 150
        case 50:
            milestone = 50
        case 1:
            milestone = 1
        default:
            milestone = nil
        }
        
        // If we hit a milestone and haven't prompted for it yet
        if let milestone = milestone {
            let key = "reviewPrompted_\(milestone)days"
            if !UserDefaults.standard.bool(forKey: key) {
                requestReview()
                UserDefaults.standard.set(true, forKey: key)
            }
        }
    }
    
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [UserProfile.self, CooperTest.self])
}
