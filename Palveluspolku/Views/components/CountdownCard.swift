//
//  CountdownCard.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

// Views/Components/CountdownCard.swift
import SwiftUI
import ConfettiSwiftUI

struct CountdownCard: View {
    let profile: UserProfile?
    
    @State private var confettiTrigger: Int = 0

    private var daysServed: Int {
        guard let profile = profile,
              let startDate = profile.serviceStartDate,
              startDate <= Date() else {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
    }
    
    
    private var daysRemaining: Int {
        guard let profile = profile else { return 0 }
        
        if let start = profile.serviceStartDate, start > Date() {
            // Pre-service: days until start
            return Calendar.current.dateComponents([.day], from: Date(), to: start).day ?? 0
        } else if let end = profile.serviceEndDate, end > Date() {
            // During service: days until end
            return Calendar.current.dateComponents([.day], from: Date(), to: end).day ?? 0
        }
        
        return 0
    }
    
    private var countdownText: String {
        guard let profile = profile else { return "Aseta palveluspäivät" }
        
        if let start = profile.serviceStartDate, start > Date() {
            return "päivää palveluksen alkuun"
        } else if let end = profile.serviceEndDate, end > Date() {
            return "päivää kotiinlähtöön"
        } else {
            return "Palvelus suoritettu"
        }
    }
    
    private var phaseColor: Color {
        guard let profile = profile else { return .gray }
        
        if let start = profile.serviceStartDate, start > Date() {
            return .blue
        } else if let end = profile.serviceEndDate, end > Date() {
            return .green
        }
        return .gray
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if profile == nil {
                // No dates set yet
                Text("Tervetuloa!")
                    .font(.title2.bold())
                
                Text("Aseta palveluspäivät aloittaaksesi")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                // Show countdown
                Text("\(daysRemaining)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(phaseColor)
                
                Text(countdownText)
                    .font(.headline)
                
                // Progress bar for during service
                if let start = profile?.serviceStartDate,
                   let end = profile?.serviceEndDate,
                   start < Date() && end > Date() {
                    
                    let progress = calculateProgress(start: start, end: end)
                    
                    ProgressView(value: progress)
                        .tint(.green)
                        .padding(.top, 8)
                    
                    Text("\(Int(progress * 100))% suoritettu")
                        .font(.callout.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(phaseColor.opacity(0.1))
        .cornerRadius(16)
        .confettiCannon(
            trigger: $confettiTrigger,
            num: 40,
            confettis: [.text("💪"), .text("🎖️"), .text("⭐️"), .text("✨")],
            colors: [.green, .yellow, .blue],
            confettiSize: 15,
            repetitions: 2,
            repetitionInterval: 0.3
        )
        .onAppear {
            // Confetti on 10th day of service
            if daysServed == 10 && !UserDefaults.standard.bool(forKey: "hasShown10DayConfetti") {
                confettiTrigger += 1
                UserDefaults.standard.set(true, forKey: "hasShown10DayConfetti")
            }
        }
    }
    
    private func calculateProgress(start: Date, end: Date) -> Double {
        let total = end.timeIntervalSince(start)
        let elapsed = Date().timeIntervalSince(start)
        return max(0, min(1, elapsed / total))
    }
}
