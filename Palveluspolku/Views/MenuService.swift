//
//  MenuService.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//

import Foundation

// MARK: - Varuskunta Model
//struct Varuskunta: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//    let slug: String
//    
//    static let all: [Varuskunta] = [
//        Varuskunta(name: "Falkonetti, Niinisalo", slug: "FalkonettiNiinisalo"),
//        Varuskunta(name: "Cirrus, Kuopio", slug: "CirrusKuopio"),
//        Varuskunta(name: "Ankkuri, Upinniemi", slug: "AnkkuriUpinniemi"),
//        // Add more as you find them
//    ]
//}
struct Varuskunta: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let slug: String
    
    static let all: [Varuskunta] = [
        Varuskunta(name: "Ankkuri, Upinniemi", slug: "AnkkuriUpinniemi"),
        Varuskunta(name: "Cirrus, Kuopio", slug: "CirrusKuopio"),
        Varuskunta(name: "Creutz, Dragsvik", slug: "CreutzDragsvik"),
        Varuskunta(name: "Falkonetti, Niinisalo", slug: "FalkonettiNiinisalo"),
        Varuskunta(name: "Hilma, Suomenlinna", slug: "HilmaSuomenlinna"),
        Varuskunta(name: "Hoikanhovi, Kajaani", slug: "HoikanhoviKajaani"),
        Varuskunta(name: "Ignatius, Helsinki", slug: "IgnatiusHelsinki"),
        Varuskunta(name: "Kotka, Utti", slug: "KotkaUtti"),
        Varuskunta(name: "Liesi, Orava", slug: "LiesiOrava"),
        Varuskunta(name: "Linna, Vekaranjärvi", slug: "LinnaVekaranjarvi"),
        Varuskunta(name: "Luonetti, Tikkakoski", slug: "LuonettiTikkakoski"),
        Varuskunta(name: "Poiju, Turku", slug: "PoijuTurku"),
        Varuskunta(name: "Rakuuna, Lappeenranta", slug: "RakuunaLappeenranta"),
        Varuskunta(name: "Rokka, Hamina", slug: "RokkaHamina"),
        Varuskunta(name: "Ruben, Parola", slug: "RubenParola"),
        Varuskunta(name: "Rumpalipoika, Säkylä", slug: "RumpalipoikaSakyla"),
        Varuskunta(name: "Sahara, Helsinki", slug: "SaharaHelsinki"),
        Varuskunta(name: "Somero, Rovaniemi", slug: "SomeroRovaniemi"),
        Varuskunta(name: "Sääksi, Pirkkala", slug: "SaaksiPirkkala"),
        Varuskunta(name: "Tähti, Sodankylä", slug: "TahtiSodankyla"),
    ]
}


class MenuService {
    static let shared = MenuService()
    
    private let restaurantId = "f41f2207-01cf-478a-a188-d4efcd4b24cf"
    
    private init() {}
    
    func fetchMenu(for varuskunta: Varuskunta, startDate: Date = Date(), endDate: Date = Date()) async throws -> MenuResponse {
        // Build URL with varuskunta slug
        let baseURL = "https://menu.leijonacatering.fi/AromieMenus/FI/Default/Leijona/\(varuskunta.slug)/api/Common/Restaurant/RestaurantMeals"
        
        var components = URLComponents(string: baseURL)!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        components.queryItems = [
            URLQueryItem(name: "Id", value: restaurantId),
            URLQueryItem(name: "StartDate", value: formatter.string(from: startDate)),
            URLQueryItem(name: "EndDate", value: formatter.string(from: endDate))
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Request body (same for all)
        let requestBody: [String: Any] = [
            "Id": "15f995bb-ffdd-4409-81cb-a365251be564",
            "DinerGroupId": "300e8323-6377-4ccd-b5a0-41f4d4087b51",
            "NutrientGroupId": "0ea0ee0d-22c9-4e49-8a7b-8de201ddaf84",
            "DietGroupId": "87977a4e-3195-4898-b0f0-bd1736a1bbac",
            "FilterDietGroupId": NSNull(),
            "DietId": NSNull(),
            "ConceptId": NSNull(),
            "Name": "Varusmiehet, varuskunta",
            "Code": "Varusmiehet, varuskunta",
            "RestaurantId": restaurantId,
            "UniqueCode": "Varusmiehet, varuskunta",
            "IndexNumber": 65,
            "NameOrCode": "Varusmiehet, varuskunta",
            "WeekDays": ["0", "1", "2", "3", "4", "5", "6"],
            "WeekDay0": true,
            "WeekDay1": true,
            "WeekDay2": true,
            "WeekDay3": true,
            "WeekDay4": true,
            "WeekDay5": true,
            "WeekDay6": true,
            "DietType": NSNull(),
            "IsActiveSuitability": false,
            "SuitabilityDietIds": []
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Decode response
        let decoder = JSONDecoder()
        return try decoder.decode(MenuResponse.self, from: data)
    }
    
    // Helper to fetch a week of menus
    func fetchWeekMenu(for varuskunta: Varuskunta) async throws -> MenuResponse {
        let today = Date()
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        return try await fetchMenu(for: varuskunta, startDate: today, endDate: weekFromNow)
    }
}
