//
//  PayTrackerView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//

// Views/PayTrackerView.swift

import SwiftUI
import SwiftData

struct PayTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var paySettings: [PaySettings]
    @Query private var budgetEntries: [BudgetEntry]
    @Query private var profiles: [UserProfile]
    
    @State private var showingAddExpense = false
    
    private var settings: PaySettings {
        if let existing = paySettings.first {
            return existing
        } else {
            let newSettings = PaySettings(isWoman: false)
            modelContext.insert(newSettings)
            return newSettings
        }
    }
    
    private var serviceStartDate: Date? {
        profiles.first?.serviceStartDate
    }
    
    private var daysServed: Int {
        guard let startDate = serviceStartDate else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return max(0, days)
    }
    
    private var totalEarned: Double {
        settings.totalEarned(serviceStartDate: serviceStartDate)
    }
    
    private var currentDailyRate: Double {
        settings.currentDailyRate(daysServed: daysServed)
    }
    
    private var totalExpenses: Double {
        budgetEntries.reduce(0) { $0 + $1.amount }
    }
    
    private var thisMonthExpenses: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return budgetEntries
            .filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var moneyLeft: Double {
        totalEarned - totalExpenses
    }
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 20) {
                    Text("Kertynyt palkka")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("€\(totalEarned, specifier: "%.2f")")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.green)
                    
                    Text("\(daysServed) päivää palvelusta")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("Nykyinen päiväraha: €\(currentDailyRate, specifier: "%.2f")/pv")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            Section("Taloustilanne") {
                HStack {
                    Text("Ansaittu yhteensä")
                    Spacer()
                    Text("€\(totalEarned, specifier: "%.2f")")
                        .foregroundStyle(.green)
                }
                
                HStack {
                    Text("Käytetty yhteensä")
                    Spacer()
                    Text("€\(totalExpenses, specifier: "%.2f")")
                        .foregroundStyle(.red)
                }
                
                Divider()
                
                HStack {
                    Text("Jäljellä")
                        .bold()
                    Spacer()
                    Text("€\(moneyLeft, specifier: "%.2f")")
                        .bold()
                        .foregroundStyle(moneyLeft >= 0 ? .green : .red)
                }
            }
            
            Section("Tämä kuukausi") {
                HStack {
                    Text("Kuluvan kuun menot")
                    Spacer()
                    Text("€\(thisMonthExpenses, specifier: "%.2f")")
                        .foregroundStyle(.orange)
                }
            }
            
            Section {
                if budgetEntries.isEmpty {
                    ContentUnavailableView(
                        "Ei kuluja",
                        systemImage: "eurosign.circle",
                        description: Text("Lisää kuluja nähdäksesi ne täällä")
                    )
                } else {
                    ForEach(budgetEntries.sorted(by: { $0.date > $1.date }).prefix(10)) { entry in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(entry.category)
                                    .font(.headline)
                                if let notes = entry.notes {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("€\(entry.amount, specifier: "%.2f")")
                                .foregroundStyle(.red)
                        }
                    }
                    .onDelete(perform: deleteExpenses)
                }
            } header: {
                HStack {
                    Text("Viimeisimmät kulut")
                    Spacer()
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            
            Section("Seuraava palkanmaksu") {
                HStack {
                    Text("Arvioitu päivä")
                    Spacer()
                    Text(settings.nextPaymentDate().formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Arvioitu summa")
                    Spacer()
                    Text("€\(settings.nextPaymentAmount(currentRate: currentDailyRate), specifier: "%.2f")")
                        .foregroundStyle(.blue)
                }
            }
            
            Section("Päivärahaporrastus") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("• 1-165 pv: €6,10/pv")
                        .font(.caption)
                    Text("• 166-255 pv: €10,15/pv")
                        .font(.caption)
                    Text("• 256-347 pv: €14,15/pv")
                        .font(.caption)
                    
                    if settings.isWoman {
                        Text("\n+ €1,50/pv varusraha")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .navigationTitle("Varusmiespalkka")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    PaySettingsView(settings: settings)
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddBudgetEntryView()
        }
    }
    
    private func deleteExpenses(at offsets: IndexSet) {
        let sorted = budgetEntries.sorted(by: { $0.date > $1.date })
        for index in offsets {
            if index < sorted.count {
                modelContext.delete(sorted[index])
            }
        }
    }
}

struct AddBudgetEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var category: String = "Ruoka"
    @State private var notes: String = ""
    @State private var date = Date()
    
    let categories = ["Ruoka", "Matkat", "Kioski", "Puhelin", "Vaatteet", "Hygienia", "Muu"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Kulu") {
                    TextField("Summa (€)", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Kategoria", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    TextField("Lisätiedot (valinnainen)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                    
                    DatePicker("Päivämäärä", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Lisää kulu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") {
                        saveBudgetEntry()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
    
    private func saveBudgetEntry() {
        let cleanAmount = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Double(cleanAmount) else { return }
        
        let entry = BudgetEntry(
            date: date,
            amount: amountValue,
            category: category,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(entry)
        dismiss()
    }
}

struct PaySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let settings: PaySettings
    
    @State private var isWoman: Bool
    
    init(settings: PaySettings) {
        self.settings = settings
        _isWoman = State(initialValue: settings.isWoman)
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Naispuolinen alokas", isOn: $isWoman)
                
                if isWoman {
                    Text("Lisää €1,50/pv varusraha henkilökohtaisten varusteiden hankkimiseen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Varusraha")
            }
            
            Section {
                Button("Tallenna") {
                    settings.isWoman = isWoman
                    dismiss()
                }
            }
        }
        .navigationTitle("Asetukset")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PayTrackerView()
    }
    .modelContainer(for: [PaySettings.self, BudgetEntry.self, UserProfile.self])
}
