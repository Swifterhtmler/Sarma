//
//  CooperTest.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

// Views/CooperTestView.swift

import SwiftUI
import SwiftData

struct CooperTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CooperTest.date, order: .reverse) private var tests: [CooperTest]
    @State private var showingAddTest = false
    
    var body: some View {
        List {
            ForEach(tests) { test in
                HStack {
                    VStack(alignment: .leading) {
                        Text(
                            test.date.formatted(
                                .dateTime
                                    .day(.defaultDigits)
                                    .month(.abbreviated)
                                    .locale(Locale(identifier: "fi_FI"))
                            )
                        )
                        .font(.headline)
                        if let notes = test.notes {
                            Text(notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text("\(test.distance) m")
                        .font(.title3.bold())
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(tests[index])
                }
            }
        }
        .navigationTitle("Cooper-testit")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddTest = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTest) {
            AddCooperTestView()
        }
    }
}

struct AddCooperTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var distance: String = ""
    @State private var notes: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Päivämäärä", selection: $date, displayedComponents: .date)
                
                TextField("Matka (metriä)", text: $distance)
                    .keyboardType(.numberPad)
                
                TextField("Muistiinpanot (valinnainen)", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("Uusi testi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") {
                        saveTest()
                    }
                    .disabled(distance.isEmpty)
                }
            }
        }
    }
    
    private func saveTest() {
        guard let dist = Int(distance) else { return }
        
        let test = CooperTest(
            date: date,
            distance: dist,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(test)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        CooperTestView()
    }
    .modelContainer(for: [CooperTest.self])
}

