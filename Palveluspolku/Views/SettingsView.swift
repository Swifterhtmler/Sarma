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
import RevenueCat

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    
    @State private var serviceStartDate = Date()
    @State private var serviceEndDate = Date()
    @State private var garrison = ""
    @State private var showPaywall = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var promoCode = ""
    
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
            
            Section("Premium") {
                if SharedDataManager.shared.isPremium() {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("Särmä Pro aktiivinen")
                            .font(.subheadline)
                    }
                    
                    Button("Palauta ostokset") {
                        restorePurchases()
                    }
                } else {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "crown")
                                .foregroundColor(.yellow)
                            Text("Päivitä Premium-versioon")
                        }
                    }
                }
            }
            
            Section("Aktivointikoodi") {
                HStack {
                    TextField("Syötä koodi", text: $promoCode)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Button("Aktivoi") {
                        checkPromoCode()
                    } 
                    .disabled(promoCode.isEmpty)
                }
            }
            
            
        
            
            Text("Käyttöehdot: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
                .foregroundStyle(Color(.secondaryLabel))

            Text("Tietosuojakäytäntö: https://www.termsfeed.com/live/5a9d6818-381b-4b92-8b7c-d7e6b147bd4f")
                .foregroundStyle(Color(.secondaryLabel))
            
        
            
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
        .sheet(isPresented: $showPaywall) {
            RevenueCatPaywallView()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
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
            startDate: serviceStartDate,
            endDate: serviceEndDate,
            garrison: garrison.isEmpty ? nil : garrison
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func restorePurchases() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.restorePurchases()
                let isPremium = customerInfo.entitlements["Särmä Pro"]?.isActive == true
                
                SharedDataManager.shared.setIsPremium(isPremium)
                WidgetCenter.shared.reloadAllTimelines()
                
                alertTitle = "Palauta ostokset"
                alertMessage = isPremium ? "Ostokset palautettu onnistuneesti!" : "Aktiivista tilausta ei löytynyt."
                showAlert = true
            } catch {
                alertTitle = "Virhe"
                alertMessage = "Palautus epäonnistui. Yritä uudelleen."
                showAlert = true
            }
        }
    }
    
    private func checkPromoCode() {
        // Secret code for Apple reviewers
        if promoCode.lowercased() == "apple2026" {
            SharedDataManager.shared.setIsPremium(true)
            WidgetCenter.shared.reloadAllTimelines()
            
            alertTitle = "Onnistui!"
            alertMessage = "Premium aktivoitu!"
            showAlert = true
            promoCode = "" // Clear the field
        } else {
            alertTitle = "Virhe"
            alertMessage = "Virheellinen koodi"
            showAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [UserProfile.self])
}
