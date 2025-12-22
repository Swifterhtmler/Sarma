//
//  AllFeaturesSection.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

// Views/Components/AllFeaturesSection.swift
import SwiftUI

struct AllFeaturesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kaikki toiminnot")
                .font(.headline)
            
            VStack(spacing: 0) {
                FeatureRow(
                    icon: "figure.run",
                    title: "Cooper-testit",
                    color: .green,
                    destination: AnyView(CooperTestView())
                )
                Divider().padding(.leading, 56)
                
                FeatureRow(
                    icon: "calendar",
                    title: "Lomakone",
                    color: .blue,
                    destination: AnyView(LeaveCalculatorView())
                )
                
                Divider().padding(.leading, 56)
                
                FeatureRow(
                    icon: "fork.knife",
                    title: "Ruokalista",
                    color: .yellow,
                    destination: AnyView(MenuView())
                )
                
                Divider().padding(.leading, 56)
                
                
                FeatureRow(
                    icon: "eurosign.circle",
                    title: "Budjetti",
                    color: .green,
                    destination: AnyView(PayTrackerView())
                )
                
                Divider().padding(.leading, 56)
                
                
//                FeatureRow(
//                    icon: "checkmark.circle",
//                    title: "Varusteet",
//                    color: .purple,
//                    destination: AnyView(Text("Tulossa pian.."))
//                )
//                
//                Divider().padding(.leading, 56)
      
//                Divider().padding(.leading, 56)
//                
//                FeatureRow(
//                    icon: "book",
//                    title: "Tietopankki",
//                    color: .orange,
//                    destination: AnyView(Text("Coming soon"))
//                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 32)
                
                Text(title)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
    }
}
