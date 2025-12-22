//
//  PreparationView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 19.12.2025.
//

// Views/PreparationView.swift
import SwiftUI
import SwiftData

struct PreparationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [PreparationItem]
    @Query private var profiles: [UserProfile]
    
    @State private var showingAddItem = false
    
    // Ordered categories
    private var categories: [String] {
        let order = [
            "Heti",
            "Fyysinen valmistautuminen",
            "Hallinnolliset asiat",
            "Taloudelliset",
            "Viimeinen viikko"
        ]
        
        let existingCategories = Set(items.map { $0.category })
        return order.filter { existingCategories.contains($0) }
    }
    
    private func itemsInCategory(_ category: String) -> [PreparationItem] {
        items.filter { $0.category == category }
    }
    
    private var completedCount: Int {
        items.filter { $0.isCompleted }.count
    }
    
    private var totalCount: Int {
        items.count
    }
    
    private var weeksUntilService: Int? {
        guard let startDate = profiles.first?.serviceStartDate else { return nil }
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: Date(), to: startDate).weekOfYear ?? 0
        return max(0, weeks)
    }
    
    var body: some View {
        List {
            // Progress
            Section {
                VStack(spacing: 12) {
                    HStack {
                        Text("Valmius")
                            .font(.headline)
                        Spacer()
                        Text("\(completedCount) / \(totalCount)")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    
                    ProgressView(value: Double(completedCount), total: Double(max(1, totalCount)))
                        .tint(.green)
                    
                    if let weeks = weeksUntilService {
                        Text("\(weeks) viikkoa palvelukseen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Items by category
            ForEach(categories, id: \.self) { category in
                Section(category) {
                    ForEach(itemsInCategory(category)) { item in
                        HStack {
                            Button {
                                item.isCompleted.toggle()
                            } label: {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isCompleted ? .green : .gray)
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .strikethrough(item.isCompleted)
                                
                                if let weeks = item.dueWeeksBefore, weeks > 0 {
                                    Text("Tee \(weeks) viikkoa ennen")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            
                            Spacer()
                            
                            if item.isCustom {
                                Button {
                                    modelContext.delete(item)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            // Tips
            Section("Muista") {
                Text("• Aloita fyysinen harjoittelu hyvissä ajoin - ei viikkoa ennen!")
                    .font(.caption)
                Text("• Käy lääkärissä ja hammaslääkärissä ennen palvelusta")
                    .font(.caption)
                Text("• Ilmoita osoitteenmuutos maistraattiin")
                    .font(.caption)
                Text("• Tarkista varuskuntasi alokasopas netistä")
                    .font(.caption)
            }
        }
        .navigationTitle("Valmistautuminen")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddItem = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
//            ToolbarItem(placement: .topBarLeading) {
//                if !items.isEmpty {
//                    Button("Tyhjennä") {
//                        resetChecks()
//                    }
//                    .font(.caption)
//                }
//            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddPreparationItemView()
        }
        .onAppear {
            if items.isEmpty {
                populateDefaultItems()
            }
        }
    }
    
    private func resetChecks() {
        for item in items {
            item.isCompleted = false
        }
    }
    
    private func populateDefaultItems() {
        // Split into chunks to avoid compiler timeout
        
        let immediately = [
            ("Lataa Särmä ja aseta palveluspäivät", "Heti", 12),
            ("Lue varuskuntasi alokasopas", "Heti", 12),
            ("Ilmoita työnantajalle / koululle", "Heti", 12),
        ]
        
        let physical = [
            ("Tee Cooper-testi (lähtötaso)", "Fyysinen valmistautuminen", 12),
            ("Aloita säännöllinen juoksuharjoittelu", "Fyysinen valmistautuminen", 10),
            ("Lihaskuntoharjoittelu", "Fyysinen valmistautuminen", 10),
            ("Tee toinen Cooper-testi", "Fyysinen valmistautuminen", 6),
            ("Käy hammaslääkärissä", "Fyysinen valmistautuminen", 8),
            ("Käy lääkärissä tarvittaessa", "Fyysinen valmistautuminen", 6),
        ]
        
        let administrative = [
            ("Ilmoita osoitteenmuutos", "Hallinnolliset asiat", 6),
            ("Järjestä postin ohjaus", "Hallinnolliset asiat", 4),
            ("Tulosta aloittamismääräys", "Hallinnolliset asiat", 2),
            ("Tarkista henkilöllisyystodistus", "Hallinnolliset asiat", 6),
            ("Hanki Kela-kortti jos ei ole", "Hallinnolliset asiat", 6),
        ]
        
        let financial = [
            ("Peru / aseta tauolle kuntosali", "Taloudelliset", 4),
            ("Vaihda puhelinliittymä", "Taloudelliset", 4),
            ("Tarkista tilinumero", "Taloudelliset", 2),
            ("Selvitä laskujen maksu", "Taloudelliset", 3),
            ("Säästä rahaa varusteisiin", "Taloudelliset", 4),
        ]
        
        
        let lastWeek = [
            ("Tarkista Pakkauslista", "Viimeinen viikko", 1),
            ("Pakkaa tavarat", "Viimeinen viikko", 1),
            ("Tarkista matkareitit", "Viimeinen viikko", 1),
            ("Varmista aloittamismääräys mukana", "Viimeinen viikko", 0),
            ("Varaa junalippu", "Viimeinen viikko", 1),
            ("Lataa puhelin", "Viimeinen viikko", 0),
            ("Positiivinen asenne mukaan!", "Viimeinen viikko", 0),
        ]
        
        let allTasks = immediately + physical + administrative + financial + lastWeek
        
        for (title, category, weeks) in allTasks {
            let item = PreparationItem(
                title: title,
                category: category,
                isCustom: false,
                dueWeeksBefore: weeks
            )
            modelContext.insert(item)
        }
    }
}

struct AddPreparationItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var category = "Henkilökohtaiset"
    
    let categories = [
        "Heti",
        "Fyysinen valmistautuminen",
        "Hallinnolliset asiat",
        "Taloudelliset",
        "Viimeinen viikko"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Tehtävä", text: $title, axis: .vertical)
                    .lineLimit(2...4)
                
                Picker("Kategoria", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
            }
            .navigationTitle("Lisää tehtävä")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") {
                        let item = PreparationItem(
                            title: title,
                            category: category,
                            isCustom: true
                        )
                        modelContext.insert(item)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PreparationView()
    }
    .modelContainer(for: [PreparationItem.self, UserProfile.self])
}
