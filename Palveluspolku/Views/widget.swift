//
//  widget.swift
//  Palveluspolku
//
//  Created by Riku Kuisma on 4.1.2026.
//

// Note: Widget reads serviceEndDate from App Group UserDefaults (set this from the main app).

import WidgetKit
import SwiftUI
import Intents

struct WidgetEntry: TimelineEntry, Codable, Identifiable {
    let id: UUID
    let date: Date
    let endDate: Date?
    let daysLeft: Int?
}
struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(id: UUID(), date: Date(), endDate: Calendar.current.date(byAdding: .day, value: 42, to: Date()), daysLeft: 42)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let (endDate, daysLeft) = Self.loadEndDateAndDaysLeft()
        let entry = WidgetEntry(id: UUID(), date: Date(), endDate: endDate, daysLeft: daysLeft)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        let currentDate = Date()
        let (endDate, daysLeft) = Self.loadEndDateAndDaysLeft()
        let entry = WidgetEntry(id: UUID(), date: currentDate, endDate: endDate, daysLeft: daysLeft)
        // Refresh at next midnight or in 6 hours if no date
        let nextMidnight = Calendar.current.nextDate(after: currentDate, matching: DateComponents(hour: 0, minute: 0, second: 5), matchingPolicy: .nextTime) ?? currentDate.addingTimeInterval(60*60*6)
        let refreshDate = daysLeft != nil ? nextMidnight : currentDate.addingTimeInterval(60*60*6)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private static func loadEndDateAndDaysLeft() -> (Date?, Int?) {
        // Replace with your App Group identifier below and ensure the app writes the end date for the key "serviceEndDate"
        let appGroupID = "group.com.example.palveluspolku" // TODO: set your actual App Group ID
        let defaults = UserDefaults(suiteName: appGroupID)
        var endDate: Date? = defaults?.object(forKey: "serviceEndDate") as? Date
        // Fallback: also try ISO8601 string if stored as string
        if endDate == nil, let iso = defaults?.string(forKey: "serviceEndDateISO") {
            endDate = ISO8601DateFormatter().date(from: iso)
        }
        guard let endDate else { return (nil, nil) }
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfEnd = Calendar.current.startOfDay(for: endDate)
        if let diff = Calendar.current.dateComponents([.day], from: startOfToday, to: startOfEnd).day {
            return (endDate, max(diff, 0))
        }
        return (endDate, nil)
    }
}

struct WidgetEntryView : View {
    var entry: SimpleProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Palveluspolku")
                .font(.headline)
            if let days = entry.daysLeft, let end = entry.endDate {
                Text("\(days)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                Text("days left (ends \(end, style: .date))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Set service end date in the app")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
    }
}

@main
struct widget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Palveluspolku")
        .description("Days left until service ends.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

