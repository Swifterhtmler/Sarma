//
//  QuickActionsSection.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

// Views/Components/QuickActionsSection.swift
import SwiftUI

struct QuickActionsSection: View {
    let profile: UserProfile?
    
    private var isPreService: Bool {
        guard let start = profile?.serviceStartDate else { return true }
        return start > Date()
    }
    
    private var isDuringService: Bool {
        guard let start = profile?.serviceStartDate,
              let end = profile?.serviceEndDate else { return false }
        let now = Date()
        return now >= start && now < end
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pika-toiminnot")
                .font(.headline)
            
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 16
            ) {
                if isPreService {
                    // Pre-service actions
                    QuickActionCard(
                        icon: "figure.run",
                        title: "Cooper-testi",
                        subtitle: "Harjoittelu",
                        color: .green,
                        destination: AnyView(CooperTestView())
                    )
                    
                    QuickActionCard(
                        icon: "checklist",
                        title: "Valmistautuminen",
                        subtitle: "Tarkista lista",
                        color: .orange,
                        destination: AnyView(PreparationView())
                    )
                    
                    QuickActionCard(
                        icon: "backpack",
                        title: "Pakkauslista",
                        subtitle: "Mitä ottaa mukaan",
                        color: .purple,
                        destination: AnyView(PackingListView())
                    )
                    
                    QuickActionCard(
                        icon: "info.circle",
                        title: "Perustiedot",
                        subtitle: "Lue täältä",
                        color: .blue,
                        destination: AnyView(InfoView())
                    )
                } else if isDuringService {
                    // During service actions
                    QuickActionCard(
                        icon: "calendar",
                        title: "Lomakone",
                        subtitle: "Suunnittele lomat",
                        color: .blue,
                        destination: AnyView(LeaveCalculatorView())
                    )
                    
                    QuickActionCard(
                        icon: "eurosign.circle",
                        title: "Budjetti",
                        subtitle: "Seuraa menoja",
                        color: .green,
                        destination: AnyView(PayTrackerView())
                    )
                    
                    QuickActionCard(
                        icon: "figure.run",
                        title: "Kunto",
                        subtitle: "Testit",
                        color: .orange,
                        destination: AnyView(CooperTestView())
                    )
                    
                    QuickActionCard(
                        icon: "checkmark.circle",
                        title: "Varusteet",
                        subtitle: "Kirjaa varusteet",
                        color: .purple,
                        destination: AnyView(EquipmentView())
                    )
                } else {
                    // Post-service actions
                    QuickActionCard(
                        icon: "briefcase",
                        title: "Työnhaku",
                        subtitle: "Suunnittele ura",
                        color: .blue,
                        destination: AnyView(Text("Tulossa Pian"))
                    )
                    
                    QuickActionCard(
                        icon: "graduationcap",
                        title: "Opiskelu",
                        subtitle: "Hakuajat",
                        color: .purple,
                        destination: AnyView(Text("Tulossa Pian"))
                    )
                }
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
    }
}
