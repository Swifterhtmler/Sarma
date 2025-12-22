//
//  varusteetView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 20.12.2025.
//

// Views/EquipmentView.swift
import SwiftUI
import SwiftData

struct EquipmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [EquipmentItem]
    
    @State private var showingAddItem = false
    
    // Ordered categories
    private var categories: [String] {
        let order = [
            "Aseet",
            "Suojavarusteet",
            "Kantamukset",
            "Vaatteet",
            "Muu"
        ]
        
        let existingCategories = Set(items.map { $0.category })
        return order.filter { existingCategories.contains($0) }
    }
    
    private func itemsInCategory(_ category: String) -> [EquipmentItem] {
        items.filter { $0.category == category }
    }
    
    private var issuedCount: Int {
        items.filter { $0.isIssued && !$0.isReturned }.count
    }
    
    private var returnedCount: Int {
        items.filter { $0.isReturned }.count
    }
    
    var body: some View {
        List {
            // Summary
            Section {
                VStack(spacing: 12) {
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(items.count)")
                                .font(.title.bold())
                                .foregroundStyle(.blue)
                            Text("Yhteensä")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack {
                            Text("\(issuedCount)")
                                .font(.title.bold())
                                .foregroundStyle(.orange)
                            Text("Hallussa")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack {
                            Text("\(returnedCount)")
                                .font(.title.bold())
                                .foregroundStyle(.green)
                            Text("Palautettu")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Items by category
            ForEach(categories, id: \.self) { category in
                Section(category) {
                    ForEach(itemsInCategory(category)) { item in
                        EquipmentRow(item: item)
                    }
                    .onDelete { offsets in
                        deleteItems(in: category, at: offsets)
                    }
                }
            }
            
            // Tips
            Section("Muista") {
                Text("• Kirjaa sarjanumerot ylös - tarvitset ne palautuksessa")
                    .font(.caption)
                Text("• Ota kuva varusteista ja numeroista")
                    .font(.caption)
                Text("• Palauta varusteet ajoissa - myöhästyminen voi maksaa")
                    .font(.caption)
            }
        }
        .navigationTitle("Varusteet")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddItem = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddEquipmentView()
        }
        .onAppear {
            if items.isEmpty {
                populateDefaultItems()
            }
        }
    }
    
    private func deleteItems(in category: String, at offsets: IndexSet) {
        let categoryItems = itemsInCategory(category)
        for index in offsets {
            if index < categoryItems.count {
                modelContext.delete(categoryItems[index])
            }
        }
        try? modelContext.save()  // ← Add this
    }

    
    private func populateDefaultItems() {
        let weapons = [
            ("RK 62 / RK 95", "Aseet"),
            ("Pistooli", "Aseet"),
        ]
        
        let protection = [
            ("Kypärä", "Suojavarusteet"),
            ("Suojalasit", "Suojavarusteet"),
            ("Kaasunaamari", "Suojavarusteet"),
            ("Taisteluvyö", "Suojavarusteet"),
        ]
        
        let carrying = [
            ("Reppu (selkäreppu)", "Kantamukset"),
            ("Taistelutasku", "Kantamukset"),
            ("Patruunapussit", "Kantamukset"),
        ]
        
        let clothing = [
            ("Kenttäpuku M05", "Vaatteet"),
            ("Saappaat", "Vaatteet"),
            ("Talvitakki", "Vaatteet"),
            ("Makuupussi", "Vaatteet"),
        ]
        
        let allItems = weapons + protection + carrying + clothing
        
        for (name, category) in allItems {
            let item = EquipmentItem(name: name, category: category)
            modelContext.insert(item)
        }
    }
}

struct EquipmentRow: View {
    let item: EquipmentItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                if let serial = item.serialNumber, !serial.isEmpty {
                    Text("Nro: \(serial)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 12) {
                    if item.isIssued {
                        Label("Vastaanotettu", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    
                    if item.isReturned {
                        Label("Palautettu", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            Spacer()
            
            NavigationLink {
                EditEquipmentView(item: item)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AddEquipmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category = "Muu"
    @State private var serialNumber = ""
    @State private var isIssued = false
    @State private var notes = ""
    
    let categories = ["Aseet", "Suojavarusteet", "Kantamukset", "Vaatteet", "Muu"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Varuste") {
                    TextField("Nimi", text: $name)
                    
                    Picker("Kategoria", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    TextField("Sarjanumero (valinnainen)", text: $serialNumber)
                }
                
                Section {
                    Toggle("Vastaanotettu", isOn: $isIssued)
                }
                
                Section {
                    TextField("Muistiinpanot", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Lisää varuste")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") {
                        let item = EquipmentItem(
                            name: name,
                            category: category,
                            serialNumber: serialNumber.isEmpty ? nil : serialNumber,
                            isIssued: isIssued,
                            notes: notes.isEmpty ? nil : notes
                        )
                        modelContext.insert(item)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct EditEquipmentView: View {
    @Environment(\.dismiss) private var dismiss
    let item: EquipmentItem
    
    @State private var serialNumber: String
    @State private var isIssued: Bool
    @State private var isReturned: Bool
    @State private var notes: String
    
    init(item: EquipmentItem) {
        self.item = item
        _serialNumber = State(initialValue: item.serialNumber ?? "")
        _isIssued = State(initialValue: item.isIssued)
        _isReturned = State(initialValue: item.isReturned)
        _notes = State(initialValue: item.notes ?? "")
    }
    
    var body: some View {
        Form {
            Section("Tiedot") {
                LabeledContent("Nimi", value: item.name)
                LabeledContent("Kategoria", value: item.category)
                
                TextField("Sarjanumero", text: $serialNumber)
            }
            
            Section("Tila") {
                Toggle("Vastaanotettu", isOn: $isIssued)
                Toggle("Palautettu", isOn: $isReturned)
                    .disabled(!isIssued)
            }
            
            Section {
                TextField("Muistiinpanot", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Tallenna") {
                    item.serialNumber = serialNumber.isEmpty ? nil : serialNumber
                    item.isIssued = isIssued
                    item.isReturned = isReturned
                    item.notes = notes.isEmpty ? nil : notes
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EquipmentView()
    }
    .modelContainer(for: [EquipmentItem.self])
}
