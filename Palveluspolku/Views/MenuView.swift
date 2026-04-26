//
//  MenuView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//

import SwiftUI
import SwiftData

struct MenuView: View {
    @Query private var profiles: [UserProfile]
    @State private var menuData: MenuResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var selectedVaruskunta: Varuskunta {
        profile?.varuskunta ?? Varuskunta.all[0]
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Ladataan ruokalistaa...")
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Virhe: \(error)")
                            .multilineTextAlignment(.center)
                        Button("Yritä uudelleen") {
                            Task {
                                await loadMenu()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if let menuDays = menuData, !menuDays.isEmpty {
                    List(menuDays) { day in
                        Section(header: Text(day.menuDate ?? "")) {
                            if let meals = day.meals {
                                ForEach(meals) { meal in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(meal.mealName ?? "")
                                            .font(.headline)
                                        
                                        if let dishes = meal.dishes, !dishes.isEmpty {
                                            ForEach(dishes) { dish in
                                                HStack(alignment: .top) {
                                                    Text("•")
                                                    VStack(alignment: .leading) {
                                                        Text(dish.dishName ?? "")
                                                            .font(.body)
                                                        if let diet = dish.dietDetails {
                                                            Text(diet)
                                                                .font(.caption)
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Ei ruokalistaa",
                        systemImage: "fork.knife",
                        description: Text("Ruokalistaa ei ole saatavilla")
                    )
                }
            }
            .background(Color.gray.opacity(0.2))
            .navigationTitle("Ruokalista - \(selectedVaruskunta.name)")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await loadMenu()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .task {
                await loadMenu()
            }
        }
    }
    
    func loadMenu() async {
        isLoading = true
        errorMessage = nil
        
        do {
            menuData = try await MenuService.shared.fetchWeekMenu(for: selectedVaruskunta)
            // Save to SharedDataManager for widget
            SharedDataManager.shared.saveMenuResponse(menuData ?? [])
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    MenuView()
        .modelContainer(for: [UserProfile.self])
}
