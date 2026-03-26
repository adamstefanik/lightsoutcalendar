import WidgetKit
import SwiftUI

struct F1WidgetEntry: TimelineEntry {
    let date: Date
    let nextRace: Race
}

struct F1WidgetProvider: TimelineProvider {
    private static var fallbackRace: Race { F1Calendar.fallbackRaces[0] }

    func placeholder(in context: Context) -> F1WidgetEntry {
        F1WidgetEntry(date: Date(), nextRace: Self.fallbackRace)
    }

    func getSnapshot(in context: Context, completion: @escaping (F1WidgetEntry) -> Void) {
        let race = F1Calendar.nextRace ?? Self.fallbackRace
        completion(F1WidgetEntry(date: Date(), nextRace: race))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<F1WidgetEntry>) -> Void) {
        Task {
            let races = await F1APIService.shared.fetchRaces()
            F1Calendar.cachedRaces = races

            let nextRace = races.first { !$0.isCompleted } ?? races.first ?? Self.fallbackRace
            print("[F1Widget] Next race: \(nextRace.name), sessions: \(nextRace.sessions.count), apiSessions: \(nextRace.apiSessions?.count ?? -1)")
            if let first = nextRace.sessions.first {
                print("[F1Widget] First session: \(first.name) \(first.day) \(first.time)")
            }
            let entry = F1WidgetEntry(date: Date(), nextRace: nextRace)
            let refresh = Date().addingTimeInterval(3600)
            completion(Timeline(entries: [entry], policy: .after(refresh)))
        }
    }
}

struct F1CalendarWidget: Widget {
    let kind = "F1CalendarWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: F1WidgetProvider()) { entry in
            F1WidgetEntryView(entry: entry)
                .containerBackground(Color.f1Background, for: .widget)
        }
        .configurationDisplayName("F1 Kalendár")
        .description("Najbližšie preteky Formula 1 2026")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@main
struct F1WidgetBundle: WidgetBundle {
    var body: some Widget {
        F1CalendarWidget()
    }
}
