//
//  LeaveCalculatorView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//

// Views/LeaveCalculatorView.swift
import SwiftUI
import SwiftData

struct LeaveCalculatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LeaveDay.date) private var leaveDays: [LeaveDay]
    @Query private var profiles: [UserProfile]
    
    @State private var showingAddLeave = false
    @State private var showingSettings = false
    
    // Load from UserDefaults, default to 0
    @AppStorage("totalLeaveAllowance") private var totalLeaveAllowance = 0
    
    private var usedLeaveDays: Int {
        leaveDays.filter { $0.leaveType == "Regular" }.count
    }
    
    private var remainingLeaveDays: Int {
        totalLeaveAllowance - usedLeaveDays
    }
    
    var body: some View {
        List {
            // Summary section
            Section {
                VStack(spacing: 16) {
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(totalLeaveAllowance)")
                                .font(.title.bold())
                                .foregroundStyle(.blue)
                            Text("Yhteensä")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack {
                            Text("\(usedLeaveDays)")
                                .font(.title.bold())
                                .foregroundStyle(.orange)
                            Text("Käytetty")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack {
                            Text("\(remainingLeaveDays)")
                                .font(.title.bold())
                                .foregroundStyle(.green)
                            Text("Jäljellä")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button("Aseta lomapäivien määrä") {
                        showingSettings = true
                    }
                    .padding(10)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .background(Color(.blue))
                    .cornerRadius(10)
            
                    
                }
                .padding(.vertical, 8)
            }
            
            // Upcoming leave
            Section("Tulevat lomat") {
                if leaveDays.filter({ $0.date > Date() }).isEmpty {
                    ContentUnavailableView(
                        "Ei tulevia lomia",
                        systemImage: "calendar.badge.plus",
                        description: Text("Lisää lomapäiviä suunnitellaksesi lomasi")
                    )
                } else {
                    ForEach(leaveDays.filter { $0.date > Date() }) { leave in
                        LeaveRow(leave: leave)
                    }
                    .onDelete(perform: deleteLeave)
                }
            }
            
            // Past leave
            if !leaveDays.filter({ $0.date <= Date() }).isEmpty {
                Section("Menneet lomat") {
                    ForEach(leaveDays.filter { $0.date <= Date() }.reversed()) { leave in
                        LeaveRow(leave: leave)
                    }
                    .onDelete(perform: deleteLeave)
                }
            }
            
            // Tips
            Section("Vinkkejä") {
                Text("• Suunnittele lomat etukäteen")
                    .font(.caption)
                Text("• Yhdistä lomapäivät viikonloppuihin")
                    .font(.caption)
                Text("• Pyydä lomaa hyvissä ajoin")
                    .font(.caption)
            }
        }
        .navigationTitle("Lomakone")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddLeave = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddLeave) {
            AddLeaveView()
        }
        .sheet(isPresented: $showingSettings) {
            LeaveSettingsView(totalAllowance: $totalLeaveAllowance)
        }
    }
    
    private func deleteLeave(at offsets: IndexSet) {
        let upcoming = leaveDays.filter { $0.date > Date() }
        for index in offsets {
            if index < upcoming.count {
                modelContext.delete(upcoming[index])
            }
        }
    }
}

struct LeaveRow: View {
    let leave: LeaveDay
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(leave.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                
                HStack {
                    Text(leave.leaveType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if leave.approved {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                
                if let notes = leave.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

struct AddLeaveView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var leaveType = "Regular"
    @State private var approved = false
    @State private var notes = ""
    
    var numberOfDays: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return days + 1 // end and start dates included
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Päivämäärät") {
                    DatePicker("Alkaen", selection: $startDate, displayedComponents: .date)
                    DatePicker("Päättyen", selection: $endDate, in: startDate..., displayedComponents: .date)
                    
                    Text("\(numberOfDays) päivää")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    Picker("Tyyppi", selection: $leaveType) {
                        Text("Normaali loma").tag("Regular")
                        Text("Viikonloppu").tag("Weekend")
                        Text("Erikoisloma").tag("Special")
                    }
                    
                    Toggle("Hyväksytty", isOn: $approved)
                }
                
                Section {
                    TextField("Muistiinpanot (valinnainen)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Lisää loma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") {
                        saveLeave()
                    }
                }
            }
        }
    }
    
    private func saveLeave() {
        // Create a leave entry for each day in the range
        let calendar = Calendar.current
        var currentDate = startDate
        
        while currentDate <= endDate {
            let leave = LeaveDay(
                date: currentDate,
                leaveType: leaveType,
                approved: approved,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(leave)
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate.addingTimeInterval(86400)
        }
        
        dismiss()
    }
}

struct LeaveSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var totalAllowance: Int
    
    @State private var allowanceText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Lomapäivien määrä", text: $allowanceText)
                        .keyboardType(.numberPad)
                    
                    Text("Lomapäivien määrä vaihtelee palveluksen pituuden mukaan. Kysy esimieheltäsi tai tarkista lomaoikeutesi.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Lomapäivät")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") {
                        if let days = Int(allowanceText) {
                            totalAllowance = days
                        }
                        dismiss()
                    }
                    .disabled(allowanceText.isEmpty)
                }
            }
            .onAppear {
                allowanceText = "\(totalAllowance)"
            }
        }
    }
}

#Preview {
    NavigationStack {
        LeaveCalculatorView()
    }
    .modelContainer(for: [LeaveDay.self, UserProfile.self])
}
