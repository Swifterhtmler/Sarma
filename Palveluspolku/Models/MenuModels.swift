//
//  MenuModels.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 18.12.2025.
//

import Foundation

// MARK: - Response is an array of MenuDay objects
typealias MenuResponse = [MenuDay]

struct MenuDay: Codable, Identifiable {
    var id: String { date ?? UUID().uuidString }
    let menuDate: String?
    let date: String?
    let meals: [Meal]?
    
    enum CodingKeys: String, CodingKey {
        case menuDate = "MenuDate"
        case date = "Date"
        case meals = "Meals"
    }
}

struct Meal: Codable, Identifiable {
    var id: String { mealId ?? UUID().uuidString }
    let mealId: String?
    let mealName: String?
    let dishes: [Dish]?
    
    enum CodingKeys: String, CodingKey {
        case mealId = "MealId"
        case mealName = "MealName"
        case dishes = "Dishes"
    }
}

struct Dish: Codable, Identifiable {
    var id: String { dishId ?? UUID().uuidString }
    let dishId: String?
    let dishName: String?
    let dietDetails: String?
    
    enum CodingKeys: String, CodingKey {
        case dishId = "DishId"
        case dishName = "DishName"
        case dietDetails = "DietDetails"
    }
}
