//
//  ServiceCountdownWidget.swift
//  ServiceCountdownWidget
//
//  Created by Riku Kuisma on 6.1.2026.
//

// ServiceCountdownWidget.swift
import WidgetKit
import SwiftUI

struct ServiceCountdownEntry: TimelineEntry {
    let date: Date
    let daysRemaining: Int?
    let serviceStartDate: Date?
    let serviceEndDate: Date?
    let garrison: String?
    let isPreService: Bool
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ServiceCountdownEntry {
        ServiceCountdownEntry(
            date: Date(),
            daysRemaining: 100,
            serviceStartDate: Date(),
            serviceEndDate: Date(),
            garrison: "Varuskunta",
            isPreService: false
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ServiceCountdownEntry) -> Void) {
        let entry = makeEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ServiceCountdownEntry>) -> Void) {
        let entry = makeEntry()
        
        // Update at midnight each day
        let tomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        
        completion(timeline)
    }
    
    private func makeEntry() -> ServiceCountdownEntry {
        let data = SharedDataManager.shared.loadServiceData()
        
        let now = Date()
        var daysRemaining: Int? = nil
        var isPreService = false
        
        if let startDate = data?.serviceStartDate, startDate > now {
            // Pre-service: show days until start
            daysRemaining = Calendar.current.dateComponents([.day], from: now, to: startDate).day ?? 0
            isPreService = true
        } else if let endDate = data?.serviceEndDate, endDate > now {
            // During service: show days until end
            daysRemaining = Calendar.current.dateComponents([.day], from: now, to: endDate).day ?? 0
            isPreService = false
        } else if data?.serviceEndDate != nil {
            // Service complete
            daysRemaining = 0
            isPreService = false
        }
        
        return ServiceCountdownEntry(
            date: Date(),
            daysRemaining: daysRemaining,
            serviceStartDate: data?.serviceStartDate,
            serviceEndDate: data?.serviceEndDate,
            garrison: data?.garrison,
            isPreService: isPreService
        )
    }
}

struct ServiceCountdownWidgetEntryView: View {
    var entry: ServiceCountdownEntry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        Group {
            // Check if user is premium
            if !SharedDataManager.shared.isPremium() {
                // Show locked state for free users
                lockedView
            } else if let days = entry.daysRemaining {
                // Show countdown for premium users
                if widgetFamily == .systemSmall {
                    smallWidgetView(days: days)
                } else {
                    mediumWidgetView(days: days)
                }
            } else {
                // Premium but no date set
                noDateView
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
    
    // MARK: - Locked View (Free Users)
    private var lockedView: some View {
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
    
    // MARK: - Small Widget View (Premium)
    private func smallWidgetView(days: Int) -> some View {
        VStack(spacing: 8) {
            Text("\(days)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(entry.isPreService ? .blue : .green)
            
            Text(entry.isPreService ? "päivää alkuun" : (days == 1 ? "päivä jäljellä" : "päivää jäljellä"))
                .font(.caption)
                .foregroundColor(.secondary)
                .minimumScaleFactor(0.7)
        }
    }
    
    // MARK: - Medium Widget View (Premium)
    private func mediumWidgetView(days: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.isPreService ? "Palvelukseen" : "Kotiutukseen")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(days)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(entry.isPreService ? .blue : .green)
                
                Text(days == 1 ? "päivä" : "päivää")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let garrison = entry.garrison {
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                        .foregroundColor(entry.isPreService ? .blue : .green)
                    Text(garrison)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding()
    }
    
    // MARK: - No Date Set View (Premium)
    private var noDateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("Aseta palveluspäivät")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct ServiceCountdownWidget: Widget {
    let kind: String = "ServiceCountdownWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ServiceCountdownWidgetEntryView(entry: entry)
                .widgetURL(URL(string: "palveluspolku://premium"))
        }
        .configurationDisplayName("Palveluksen laskuri")
        .description("Näyttää päivät kotiutukseen")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    ServiceCountdownWidget()
} timeline: {
    ServiceCountdownEntry(date: .now, daysRemaining: 150, serviceStartDate: nil, serviceEndDate: Date(), garrison: "Vekaranjärvi", isPreService: false)
}

#Preview(as: .systemMedium) {
    ServiceCountdownWidget()
} timeline: {
    ServiceCountdownEntry(date: .now, daysRemaining: 89, serviceStartDate: nil, serviceEndDate: Date(), garrison: "Santahamina", isPreService: false)
}
