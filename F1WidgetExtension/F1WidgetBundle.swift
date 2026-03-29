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
            // Generate entries every minute for the next 2 hours
            var entries: [F1WidgetEntry] = []
            let now = Date()
            for i in 0..<120 {
                let entryDate = now.addingTimeInterval(Double(i) * 60)
                entries.append(F1WidgetEntry(date: entryDate, nextRace: nextRace))
            }
            let refresh = now.addingTimeInterval(2 * 3600)
            completion(Timeline(entries: entries, policy: .after(refresh)))
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
        .configurationDisplayName("F1 Calendar")
        .description("Your essential F1 companion")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

@main
struct F1WidgetBundle: WidgetBundle {
    var body: some Widget {
        F1CalendarWidget()
    }
}
