//
//  jobSearchView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 11.1.2026.
//

import SwiftUI
import Foundation
import ConfettiSwiftUI
import SwiftData


struct särmäwrappedView: View {
    @Query private var profiles: [UserProfile]
    @Query private var paySettings: [PaySettings]
    @Query private var equipmentItems: [EquipmentItem]
    @Query(sort: \CooperTest.distance, order: .reverse) private var cooperTests: [CooperTest]
    @State private var trigger: Int = 0
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var paySetting: PaySettings? {
        paySettings.first
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
    
    private var totalEarned: Double {
        guard let paySetting = paySetting,
              let profile = profile else {
            return 0.0
        }
        return paySetting.totalEarned(serviceStartDate: profile.serviceStartDate)
    }
    
    private var currentDailyRate: Double {
        guard let paySetting = paySetting else {
            return 0.0
        }
        return paySetting.currentDailyRate(daysServed: daysServed)
    }

    private var equipmentCount: Int {
        equipmentItems.count
    }
    
    private var coffeeEquivalent: Int {
        let coffeePrice = 3.0
        return Int(totalEarned / coffeePrice)
    }

    private var cooperImprovement: Int? {
        guard cooperTests.count >= 2 else { return nil }
        
        // cooperTests is sorted by distance (best first)
        // So last one is the worst/earliest
        let bestDistance = cooperTests.first?.distance ?? 0
        let firstDistance = cooperTests.last?.distance ?? 0
        
        let improvement = bestDistance - firstDistance
        return improvement > 0 ? improvement : nil
    }
    
    private var bestCooperDistance: Int? {
        cooperTests.first?.distance  // Already sorted by distance descending
    }
    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//             
//                Text("Armeijasi tilastoina")
//                    .fontWeight(.bold)
//                    .font(.largeTitle)
//                    .foregroundStyle(.green)
//                
//                // Stats cards
//                VStack(spacing: 10) {
//                    StatCard(title: "Palveluksesta suoritettu", value: "100 %")
//                    StatCard(title: "Päiviä palveltu", value: "\(daysServed)")
//                    StatCard(title: "Päiviä jäljellä",
//                   value: "0")
//                    
//                    
//                    StatCard(title: "Ansaittu yhteensä", value: String(format: "%.2f €", totalEarned))
////                    StatCard(title: "Nykyinen päiväraha", value: String(format: "%.2f €", currentDailyRate))
//                    StatCard(title: "Varusteita lisätty", value: "\(equipmentCount) kpl")
//                    
//                    if let bestDistance = bestCooperDistance {
//                        StatCard(title: "Paras Cooper-testi", value: "\(bestDistance) m")
//                    }
//                    if let improvement = cooperImprovement {
//                            StatCard(title: "Cooper parannus", value: "+\(improvement) m 📈")
//                        }
//                }
//            }
//            .padding()
//        }
//    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
             
                Text("Armeijasi tilastoina")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                
                // Stats cards
                VStack(spacing: 10) {
                    StatCard(title: "Palveluksesta suoritettu", value: "100 %")
                    StatCard(title: "Päiviä palveltu", value: "\(daysServed)")
                    StatCard(title: "Päiviä jäljellä", value: "0")
                    
                    StatCard(title: "Ansaittu yhteensä", value: String(format: "%.2f €", totalEarned))
                    StatCard(title: "Kahvikuppeja", value: "☕️ \(coffeeEquivalent) kpl")
                    StatCard(title: "Varusteita lisätty", value: "\(equipmentCount) kpl")
                    
                    if let bestDistance = bestCooperDistance {
                        StatCard(title: "Paras Cooper-testi", value: "\(bestDistance) m")
                    }
                    if let improvement = cooperImprovement {
                        StatCard(title: "Cooper parannus", value: "+\(improvement) m 📈")
                    }
                }
            }
            .padding()
        }
        .confettiCannon(
            trigger: $trigger,
            num: 50,
            confettis: [.text("🎉"), .text("🎊"), .text("⭐️"), .text("✨"), .text("🏅"),.text("🏋️‍♂️"), .shape(.circle)],
            colors: [.green, .yellow, .orange, .blue],
            confettiSize: 19,
            repetitions: 3,
            repetitionInterval: 0.5
        )
        .onAppear {
            // Trigger confetti when view appears
//            if !UserDefaults.standard.bool(forKey: "hasShownWrappedConfetti") {
                trigger += 1
//                UserDefaults.standard.set(true, forKey: "hasShownWrappedConfetti")
//            }
        }
    }
    
    
}

// Simple stat card component
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    särmäwrappedView()
        .modelContainer(for: [UserProfile.self, PaySettings.self, EquipmentItem.self, CooperTest.self])
}
