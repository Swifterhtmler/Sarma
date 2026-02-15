//
//  File.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 23.12.2025.
//

// Views/OnboardingView.swift
import SwiftUI
import SwiftData
import WidgetKit
#if os(iOS)
import UIKit
#endif

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var hasCompletedOnboarding: Bool
    @Query private var profiles: [UserProfile]
    
    @State private var currentPage = 0
    @State private var serviceStartDate = Date()
    @State private var serviceEndDate: Date
    @State private var garrison = ""
    
    init(hasCompletedOnboarding: Binding<Bool>) {
        self._hasCompletedOnboarding = hasCompletedOnboarding
        // Set default end date to 6 months from now
        let sixMonthsLater = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        _serviceEndDate = State(initialValue: sixMonthsLater)
    }
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Welcome
            VStack(spacing: 40) {
                Spacer()
                
                Image(systemName: "shield.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.green)
                
                Text("Tervetuloa Särmään")
                    .font(.largeTitle.bold())
                
                Text("Valmistaudu palvelukseen, hallitse arkea ja suunnittele tulevaisuus")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button {
                    withAnimation {
                        currentPage = 1
                    }
                } label: {
                    Text("Seuraava")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .tag(0)
            
            // Page 2: Features
            VStack(spacing: 40) {
                Text("Mitä Särmä tarjoaa?")
                    .font(.title.bold())
                    .padding(.top, 60)
                
                VStack(alignment: .leading, spacing: 20) {
                    OnboardingFeatureRow(icon: "calendar", text: "Seuraa palveluksen etenemistä")
                    OnboardingFeatureRow(icon: "figure.run", text: "Cooper-testien seuranta")
                    OnboardingFeatureRow(icon: "eurosign.circle", text: "Varusmiespalkka ja budjetointi")
                    OnboardingFeatureRow(icon: "calendar.badge.clock", text: "Lomakone ja suunnittelu")
                    OnboardingFeatureRow(icon: "list.bullet", text: "Pakkauslistat ja valmistautuminen")
                }
                OnboardingFeatureRow(icon: "square.grid.2x2", text: "TJ-widgetti kotinäytölle (premium)")
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button {
                    withAnimation {
                        currentPage = 2
                    }
                } label: {
                    Text("Seuraava")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .tag(1)
            
            
            // Page 3: Widgets showcase
            VStack(spacing: 40) {
                Spacer()
                
                Text("Pidä palvelus näkyvissä")
                    .font(.title.bold())
                
                Text("Seuraa edistymistä suoraan kotinäytöltäsi")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
                
              
                Image("widget-preview")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
                
                Text("Premium-ominaisuus")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                HStack(spacing: 16) {
         
                
                    Button("Seuraava") {
                        withAnimation {
                            currentPage = 3
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .tag(2)
            
            
            
            
            // Page 3: Setup Profile
            VStack(spacing: 30) {
                Text("Aseta palveluspäiväsi")
                    .font(.title.bold())
                    .padding(.top, 60)
                
                Form {
                    Section("Palveluspäivät") {
                        DatePicker("Aloitus", selection: $serviceStartDate, displayedComponents: .date)
                        DatePicker("Kotiutus", selection: $serviceEndDate, in: serviceStartDate..., displayedComponents: .date)
                    }
                   
                    // info to tell users they can change their serving time afrerwards
                    
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        Text("Kotiutusta voi myöhemmin muuttaa asetuksissa kun tarkempi palvelusaika selviää")
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)
                    
                    
                    Section("Varuskunta") {
                        TextField("Varuskunta (valinnainen)", text: $garrison)
                    }
                }
                .scrollContentBackground(.hidden)
                
                Button {
                    saveProfileAndFinish()
                } label: {
                    Text("Aloita käyttö")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .tag(3)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private func saveProfileAndFinish() {
        // Create or update profile
        if let profile = profiles.first {
            profile.serviceStartDate = serviceStartDate
            profile.serviceEndDate = serviceEndDate
            profile.garrison = garrison.isEmpty ? nil : garrison
        } else {
            let newProfile = UserProfile(
                serviceStartDate: serviceStartDate,
                serviceEndDate: serviceEndDate,
                garrison: garrison.isEmpty ? nil : garrison
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
        
        // Mark onboarding as complete
        hasCompletedOnboarding = true
    }
}

struct OnboardingFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .modelContainer(for: [UserProfile.self])
}

