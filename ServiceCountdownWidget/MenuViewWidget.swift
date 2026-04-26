//
//  SwiftUIView.swift
//  ServiceCountdownWidgetExtension
//
//  Created by Riku Kuisma on 16.2.2026.
//

import SwiftUI
import WidgetKit

struct MenuViewWidget: View {
    let entry: Provider.Entry
    
    var body: some View {
        
        
        
        
        if SharedDataManager.shared.isPremium() {
            if let menuData = SharedDataManager.shared.loadMenuResponse(),
               let today = getTodayMenu(from: menuData) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tänään")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.blue)
                        .padding(.bottom, 5)
                    
                    ForEach(today.meals ?? []) { meal in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(meal.mealName ?? "")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(Color.blue.opacity(0.73))
                                 Divider()
                            
                            if let dishes = meal.dishes?.prefix(2) {
                                ForEach(dishes) { dish in
                                    Text("• \(dish.dishName ?? "")")
                                        .font(.caption)
                                        .lineLimit(1)
                                      
                                }
                            }
                        }
                    }
                 
                }
//                .padding()
                
           
            } else {
                Text("Ei ruokalistaa")
                    .font(.title)
            }
        } else {
    //      Text("Premium vaaditaan")
   //   .font(.title3)
 
            VStack(spacing: 12) {
                       ZStack {
                           Circle()
                               .fill(Color.orange.opacity(0.2))
                               .frame(width: 60, height: 60)
                           
                           Image(systemName: "lock.fill")
                               .font(.system(size: 28))
                               .foregroundColor(.orange)
                       }
                       
                       VStack(spacing: 4) {
                           Text("Premium-ominaisuus")
                               .font(.caption.bold())
                               .foregroundColor(.primary)
                           
                           Text("Napauta avataksesi")
                               .font(.caption2)
                               .foregroundColor(.secondary)
                       }
                   }
                   .padding()
               
            
            
        }
    }
    
    private func getTodayMenu(from menu: MenuResponse) -> MenuDay? {
        let today = Calendar.current.startOfDay(for: Date())
        return menu.first { day in
            guard let dateString = day.date,
                  let date = parseDate(dateString) else { return false }
            return Calendar.current.isDate(date, inSameDayAs: today)
        }
    }
    
   
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        // Fallback: manual parsing
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        fallbackFormatter.timeZone = TimeZone.current
        return fallbackFormatter.date(from: dateString)
    }
    
    
}

struct MenuWidget: Widget {
    let kind: String = "MenuWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MenuViewWidget(entry: entry)
                .widgetURL(URL(string: "palveluspolku://premium"))
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Ruokalista")
        .description("Näytä tämän päivän ruokalista")
        .supportedFamilies([.systemLarge]) // Large widget for menu content
    }
}


