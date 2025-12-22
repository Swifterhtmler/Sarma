//
//  HomeView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

// Views/HomeView.swift
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    // Get the profile (there should only be one)
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Big countdown card
                    CountdownCard(profile: profile)
                    
                    // Quick actions
                    QuickActionsSection(profile: profile)
                    
                    // All features
                    AllFeaturesSection()
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
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [UserProfile.self, CooperTest.self])
}
