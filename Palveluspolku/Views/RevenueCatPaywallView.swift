//
//  RevenueCatPaywallView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 6.1.2026.
//

// Views/RevenueCatPaywallView.swift
import SwiftUI
import RevenueCat
import RevenueCatUI
import WidgetKit

struct RevenueCatPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        PaywallView()
            .onPurchaseCompleted { customerInfo in
                handleSuccessfulPurchase(customerInfo: customerInfo)
            }
            .onRestoreCompleted { customerInfo in
                handleSuccessfulPurchase(customerInfo: customerInfo)
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .alert("Virhe", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
    }
    
    private func handleSuccessfulPurchase(customerInfo: CustomerInfo) {
        let isPremium = customerInfo.entitlements["Särmä Pro"]?.isActive == true
        
        if isPremium {
            // Update shared storage for widget
            SharedDataManager.shared.setIsPremium(true)
            WidgetCenter.shared.reloadAllTimelines()
            
            // Dismiss paywall
            dismiss()
        } else {
            errorMessage = "Tilaus ei ole aktiivinen. Yritä uudelleen."
            showError = true
        }
    }
}

#Preview {
    RevenueCatPaywallView()
}
