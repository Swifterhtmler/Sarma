//
//  SettingsView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//
// Views/SettingsView.swift
import SwiftUI
import SwiftData
import WidgetKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    
    @State private var serviceStartDate = Date()
    @State private var serviceEndDate = Date()
    @State private var garrison = ""
    @State private var isPremium = SharedDataManager.shared.isPremium()
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        Form {
            Section("Palveluspäivät") {
                DatePicker("Aloitus", selection: $serviceStartDate, displayedComponents: .date)
                DatePicker("Kotiutus", selection: $serviceEndDate, displayedComponents: .date)
            }
            
            Section("Varuskunta") {
                TextField("Varuskunta (valinnainen)", text: $garrison)
            }
            
            Section("Debug (Poista ennen julkaisua)") {
                Toggle("Premium Status", isOn: $isPremium)
                    .onChange(of: isPremium) { _, newValue in
                        SharedDataManager.shared.setIsPremium(newValue)
                        WidgetCenter.shared.reloadAllTimelines()
                    }
            }
            
            Section {
                Button("Tallenna") {
                    saveProfile()
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Asetukset")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Load existing profile data when view appears
            if let profile = profile {
                serviceStartDate = profile.serviceStartDate ?? Date()
                serviceEndDate = profile.serviceEndDate ?? Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
                garrison = profile.garrison ?? ""
            } else {
                // Set defaults for new profile
                serviceEndDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
            }
            // Load current premium status
            isPremium = SharedDataManager.shared.isPremium()
        }
    }
    
    private func saveProfile() {
        if let profile = profile {
            // Update existing
            profile.serviceStartDate = serviceStartDate
            profile.serviceEndDate = serviceEndDate
            profile.garrison = garrison
        } else {
            // Create new
            let newProfile = UserProfile(
                serviceStartDate: serviceStartDate,
                serviceEndDate: serviceEndDate,
                garrison: garrison
            )
            modelContext.insert(newProfile)
        }
        
        try? modelContext.save()
        
        // Update widget with new data
        SharedDataManager.shared.saveServiceData(
            endDate: serviceEndDate,
            garrison: garrison.isEmpty ? nil : garrison
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [UserProfile.self])
}
