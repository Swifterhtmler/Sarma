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
    let serviceEndDate: Date?
    let garrison: String?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ServiceCountdownEntry {
        ServiceCountdownEntry(date: Date(), daysRemaining: 100, serviceEndDate: Date(), garrison: "Varuskunta")
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
        
        let daysRemaining: Int? = {
            guard let endDate = data?.serviceEndDate else { return nil }
            return SharedDataManager.shared.daysRemaining(until: endDate)
        }()
        
        return ServiceCountdownEntry(
            date: Date(),
            daysRemaining: daysRemaining,
            serviceEndDate: data?.serviceEndDate,
            garrison: data?.garrison
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
                .foregroundColor(.green)
            
            Text(days == 1 ? "päivä jäljellä" : "päivää jäljellä")
                .font(.caption)
                .foregroundColor(.secondary)
                .minimumScaleFactor(0.7)
        }
    }
    
    // MARK: - Medium Widget View (Premium)
    private func mediumWidgetView(days: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Kotiutukseen")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(days)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                
                Text(days == 1 ? "päivä" : "päivää")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let garrison = entry.garrison {
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
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
            Text("Aseta kotiutuspäivä")
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
    ServiceCountdownEntry(date: .now, daysRemaining: 150, serviceEndDate: Date(), garrison: "Vekaranjärvi")
}

#Preview(as: .systemMedium) {
    ServiceCountdownWidget()
} timeline: {
    ServiceCountdownEntry(date: .now, daysRemaining: 89, serviceEndDate: Date(), garrison: "Santahamina")
}
