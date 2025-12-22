//
//  ContentView.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 17.12.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, StorageItem.self])
}

