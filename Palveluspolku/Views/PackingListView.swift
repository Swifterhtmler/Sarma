//
//  PackingListView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 19.12.2025.
//

// Views/PackingListView.swift
import SwiftUI
import SwiftData

struct PackingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PackingItem.category) private var items: [PackingItem]
    
    @State private var showingAddItem = false
    
//    private var categories: [String] {
//        Array(Set(items.map { $0.category })).sorted()
//    }
    
    private var categories: [String] {
        let order = [
            "Pakollinen",
            "Lääkkeet",
            "Vaatteet",
            "Hygienia",
            "Hyödylliset",
            "Ajanviete"
        ]
        
        let existingCategories = Set(items.map { $0.category })
        
        return order.filter { existingCategories.contains($0) }
    }
    
    private func itemsInCategory(_ category: String) -> [PackingItem] {
        items.filter { $0.category == category }
    }
    
    private var checkedCount: Int {
        items.filter { $0.isChecked }.count
    }
    
    private var totalCount: Int {
        items.count
    }
    
    var body: some View {
        List {
            // Progress
            Section {
                VStack(spacing: 8) {
                    HStack {
                        Text("Valmiina")
                            .font(.headline)
                        Spacer()
                        Text("\(checkedCount) / \(totalCount)")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                    
                    ProgressView(value: Double(checkedCount), total: Double(max(1, totalCount)))
                        .tint(.blue)
                }
            }
            
            // Items by category
            ForEach(categories, id: \.self) { category in
                Section(category) {
                    ForEach(itemsInCategory(category)) { item in
                        HStack {
                            Button {
                                item.isChecked.toggle()
                            } label: {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isChecked ? .green : .gray)
                            }
                            .buttonStyle(.plain)
                            
                            Text(item.name)
                                .strikethrough(item.isChecked)
                            
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
            
            // Tips section with tips
            Section("Vinkkejä") {
                Text("• Saavu jo puolenpäivän aikoihin - ehdit sovittaa varusteet rauhassa")
                    .font(.caption)
                
                Text("• PALJON sukkia! Tarvitset 2-3 paria päivässä")
                    .font(.caption)
                
                Text("• Merkitse kaikki tavarat nimellä tai nimikirjaimilla")
                    .font(.caption)
                
                Text("• Älä ota liikaa: kaappi on ~30cm leveä")
                    .font(.caption)
                
                Text("• Hanki kello jossa taustavalo - sitä tarvitaan!")
                    .font(.caption)
                
                Text("• Säästä kaikki matka liput matkakorvauksia varten")
                    .font(.caption)
                
                Text("• Tarkista varuskuntakohtaiset ohjeet alokasoppaasta")
                    .font(.caption)
            }
        }
        .navigationTitle("Pakkauslista")
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
            AddPackingItemView()
        }
        .onAppear {
            if items.isEmpty {
                populateDefaultItems()
            }
        }
    }
    
    private func resetChecks() {
        for item in items {
            item.isChecked = false
        }
    }
    
    private func populateDefaultItems() {
        let mandatory = [
            ("Henkilöllisyystodistus", "Pakollinen"),
            ("Palveluksen aloittamismääräys", "Pakollinen"),
            ("Tilinumero (IBAN-muodossa)", "Pakollinen"),
            ("Kela-kortti (sairausvakuutuskortti)", "Pakollinen"),
            ("Puhelin", "Pakollinen"),
        ]
        
        let medical = [
            ("Omat lääkkeet (~2 viikon tarve)", "Lääkkeet"),
            ("Reseptit", "Lääkkeet"),
            ("Rokotuskortti", "Lääkkeet"),
            ("Kipulääke (burana, panadol)", "Lääkkeet"),
            ("Laastarit", "Lääkkeet"),
            ("Rakkolaastarit", "Lääkkeet"),
        ]
        
        let hygiene = [
            ("Hammasharja + tahna", "Hygienia"),
            ("Saippua / suihkugeeli", "Hygienia"),
            ("Shampoo", "Hygienia"),
            ("Deodorantti", "Hygienia"),
            ("Partakone / -höylä", "Hygienia"),
            ("Pyyhkeet (1-2 kpl)", "Hygienia"),
            ("Kynsileikkuri / -sakset", "Hygienia"),
            ("Kosteuspyyhkeet", "Hygienia"),
        ]
        
        let clothes = [
            ("Omat alusvaatteet", "Vaatteet"),
            ("Sukat (paljon!)", "Vaatteet"),
            ("Pitkät aluskerrastot (talvi)", "Vaatteet"),
            ("Omat pohjalliset", "Vaatteet"),
            ("vapaa-ajan vaatteet", "Vaatteet"),
            ("Salivaatteet", "Vaatteet"),
        ]
        
//        let forWomen = [
//            ("Kuukautissuojat", "Naisille"),
//            ("Harja", "Naisille"),
//            ("Pinnit ja ponnarit", "Naisille"),
//            ("Hiuslakka / geeli / muotovaahto", "Naisille"),
//            ("Kasvorasva", "Naisille"),
//            ("Huulirasva", "Naisille"),
//        ]
        
        let useful = [
            ("Rannekello (taustavalo!)", "Hyödylliset"),
            ("Käteistä rahaa", "Hyödylliset"),
            ("Otsalamppu / taskulamppu", "Hyödylliset"),
            ("Puukko / monitoimityökalu", "Hyödylliset"),
            ("Matka-akku (powerbank)", "Hyödylliset"),
            ("Kuulokkeet", "Hyödylliset"),
            ("Urheiluteippi", "Hyödylliset"),
            ("Laturi (USB-A ja -C)", "Hyödylliset"),
            ("lukuvalo","Hyödylliset"),
            ("Juomapullo", "Ajanviete"),
        ]
        
        let entertainment = [
            ("Kirja / lehti", "Ajanviete"),
            ("Muistiinpanovälineet (vihko, kynä)", "Ajanviete"),
            ("Naposteltavaa (ei turhaa)", "Ajanviete"),
        ]
        
        let allItems = mandatory + medical + hygiene + clothes + useful + entertainment
        
        for (name, category) in allItems {
            let item = PackingItem(name: name, category: category)
            modelContext.insert(item)
        }
    }
}  // ← PackingListView ENDS HERE

// NOW AddPackingItemView is OUTSIDE (sibling, not child)
struct AddPackingItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var itemName = ""
    @State private var category = "Muut"
    
    let categories = ["Pakollinen", "Lääkkeet", "Hygienia", "Vaatteet", "Hyödylliset", "Ajanviete"]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Tavara", text: $itemName)
                
                Picker("Kategoria", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
            }
            .navigationTitle("Lisää tavara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") {
                        let item = PackingItem(name: itemName, category: category, isCustom: true)
                        modelContext.insert(item)
                        dismiss()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PackingListView()
    }
    .modelContainer(for: [PackingItem.self])
}
