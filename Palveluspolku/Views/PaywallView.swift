//
//  PaywallView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 6.1.2026.
//

// Views/PaywallView.swift
import SwiftUI
import WidgetKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                
                // Title
                VStack(spacing: 8) {
                    Text("Särmä Premium")
                        .font(.largeTitle.bold())
                    
                    Text("Avaa kaikki ominaisuudet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    PremiumFeatureRow(icon: "chart.bar.fill", text: "Widget kotinäytölle")
                    PremiumFeatureRow(icon: "clock.fill", text: "Yksityiskohtainen seuranta")
                    PremiumFeatureRow(icon: "star.fill", text: "Lisäominaisuuksia tulossa")
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                
                Spacer()
                
                // Price and CTA
                VStack(spacing: 16) {
                    Button {
                        purchasePremium()
                    } label: {
                        VStack(spacing: 4) {
                            Text("Aloita Premium")
                                .font(.headline)
                            Text("4,99€ / kuukausi")
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    
                    Button("Palauta ostokset") {
                        restorePurchases()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Button("Ei kiitos") {
                        dismiss()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func purchasePremium() {
        // TODO: Integrate with RevenueCat here
        // For now, just unlock it
        SharedDataManager.shared.setIsPremium(true)
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
    
    private func restorePurchases() {
        // TODO: Integrate with RevenueCat here
        // For now, check if already purchased
        if SharedDataManager.shared.isPremium() {
            dismiss()
        }
    }
}

struct PremiumFeatureRow: View {
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
    PaywallView()
}
