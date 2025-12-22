//
//  intoTab.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 19.12.2025.
//

// Views/InfoView.swift
import SwiftUI

struct InfoView: View {
    var body: some View {
        List {
            Section("Tietoa Särmästä") {
                Text("Särmä auttaa sinua valmistautumaan, hallitsemaan ja suunnittelemaan asepalvelustasi.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Section("Hyödyllisiä linkkejä") {
                Link(destination: URL(string: "https://puolustusvoimat.fi/")!) {
                    LinkRow(title: "Puolustusvoimat", subtitle: "Virallinen sivusto")
                }
                
                Link(destination: URL(string: "https://puolustusvoimat.fi/joukko-osastot")!) {
                    LinkRow(title: "Joukko-osastot", subtitle: "Alokasoppaat")
                }
                
                Link(destination: URL(string: "https://intti.fi/etusivu")!) {
                    LinkRow(title: "Intti.fi", subtitle: "Tietoa asepalveluksesta")
                }
            }
            
            Section("Vinkkejä") {
                TipRow(text: "Aloita fyysinen harjoittelu 3 kuukautta ennen")
                TipRow(text: "Käy hammaslääkärissä ennen palvelusta")
                TipRow(text: "Säästä kaikki matka liput matkakorvauksia varten")
                TipRow(text: "Ole ajoissa paikalla - saavu puolenpäivän aikoihin")
            }
            
//            Section("Palaute") {
//                Text("Kehitysideoita? Ongelmia? Ota yhteyttä:")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                
//    
//            }
        }
        .navigationTitle("Tietoa")
    }
}

struct LinkRow: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.caption)
                .foregroundStyle(.blue)
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.caption)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    NavigationStack {
        InfoView()
    }
}
