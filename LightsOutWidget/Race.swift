import Foundation

struct Session: Codable, Identifiable, Hashable {
    var id: String { "\(name)_\(sessionKey ?? 0)" }
    let name: String
    let day: String
    let time: String
    let isHighlighted: Bool
    let startDate: Date?
    let endDate: Date?
    let sessionKey: Int?

    init(name: String, day: String, time: String, isHighlighted: Bool, startDate: Date? = nil, endDate: Date? = nil, sessionKey: Int? = nil) {
        self.name = name
        self.day = day
        self.time = time
        self.isHighlighted = isHighlighted
        self.startDate = startDate
        self.endDate = endDate
        self.sessionKey = sessionKey
    }

    var isLive: Bool {
        guard let start = startDate, let end = endDate else { return false }
        let now = Date()
        return now >= start && now <= end
    }
}

struct Race: Identifiable, Codable {
    let id: Int
    let round: Int
    let name: String
    let shortName: String
    let city: String
    let circuit: String
    let country: String
    let countryFlag: String
    let raceDate: Date
    let qualifyingDate: Date
    let weekendStart: Date
    let sprint: Bool
    let isCanceled: Bool
    let apiSessions: [Session]?

    init(id: Int, round: Int, name: String, shortName: String, city: String,
         circuit: String, country: String, countryFlag: String,
         raceDate: Date, qualifyingDate: Date, weekendStart: Date,
         sprint: Bool, isCanceled: Bool = false, apiSessions: [Session]? = nil) {
        self.id = id
        self.round = round
        self.name = name
        self.shortName = shortName
        self.city = city
        self.circuit = circuit
        self.country = country
        self.countryFlag = countryFlag
        self.raceDate = raceDate
        self.qualifyingDate = qualifyingDate
        self.weekendStart = weekendStart
        self.sprint = sprint
        self.isCanceled = isCanceled
        self.apiSessions = apiSessions
    }

    var isCompleted: Bool { isCanceled || raceDate < Date() }

    /// Changes when sessionKeys become available (triggers task re-fire)
    var sessionKeyHash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        for session in sessions {
            hasher.combine(session.sessionKey)
        }
        return hasher.finalize()
    }

    var daysUntilRace: Int {
        max(0, Calendar.current.dateComponents([.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: raceDate)).day ?? 0)
    }

    var roundLabel: String { "R\(round)" }

    var weekendDayRange: String {
        let start = Calendar.current.component(.day, from: weekendStart)
        let end = Calendar.current.component(.day, from: raceDate)
        return String(format: "%02d-%02d", start, end)
    }

    var monthLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        fmt.locale = Locale(identifier: "en_US")
        return fmt.string(from: raceDate).uppercased()
    }

    var currentSessionBadge: String {
        let now = Date()
        let ordered = sessions.sorted {
            ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast)
        }
        // Skip live, show next upcoming
        if let next = ordered.first(where: { ($0.startDate ?? .distantPast) > now }) {
            return sessionBadgeLabel(next.name)
        }
        // All sessions passed — show last one
        if let last = ordered.last {
            return sessionBadgeLabel(last.name)
        }
        return "FP1"
    }

    private func sessionBadgeLabel(_ name: String) -> String {
        switch name {
        case "PRACTICE 1": return "FP1"
        case "PRACTICE 2": return "FP2"
        case "PRACTICE 3": return "FP3"
        case "QUALIFYING": return "QUAL"
        case "SPRINT QUALI": return "SQ"
        case "SPRINT": return "SPRINT"
        case "GRAND PRIX": return "RACE"
        default: return "FP1"
        }
    }

    var sessions: [Session] {
        if let apiSessions = apiSessions, !apiSessions.isEmpty {
            return apiSessions
        }
        // Fallback to hardcoded sessions with computed startDate from weekendStart
        let cal = Calendar.current
        if sprint {
            let day1 = weekendStart
            let day2 = cal.date(byAdding: .day, value: 1, to: weekendStart)!
            let day3 = cal.date(byAdding: .day, value: 2, to: weekendStart)!
            // Sprint: FRI / FRI / SAT / SAT / SUN
            return [
                Session(name: "PRACTICE 1",   day: "FRIDAY",   time: "13:30 - 14:30", isHighlighted: false,
                        startDate: cal.date(bySettingHour: 13, minute: 30, second: 0, of: day1),
                        endDate:   cal.date(bySettingHour: 14, minute: 30, second: 0, of: day1)),
                Session(name: "SPRINT QUALI", day: "FRIDAY",   time: "17:30 - 18:30", isHighlighted: true,
                        startDate: cal.date(bySettingHour: 17, minute: 30, second: 0, of: day1),
                        endDate:   cal.date(bySettingHour: 18, minute: 30, second: 0, of: day1)),
                Session(name: "SPRINT",       day: "SATURDAY", time: "12:00 - 13:00", isHighlighted: true,
                        startDate: cal.date(bySettingHour: 12, minute: 0, second: 0, of: day2),
                        endDate:   cal.date(bySettingHour: 13, minute: 0, second: 0, of: day2)),
                Session(name: "QUALIFYING",   day: "SATURDAY", time: "16:00 - 17:00", isHighlighted: false,
                        startDate: cal.date(bySettingHour: 16, minute: 0, second: 0, of: day2),
                        endDate:   cal.date(bySettingHour: 17, minute: 0, second: 0, of: day2)),
                Session(name: "GRAND PRIX",   day: "SUNDAY",   time: "15:00",          isHighlighted: true,
                        startDate: cal.date(bySettingHour: 15, minute: 0, second: 0, of: day3),
                        endDate:   cal.date(bySettingHour: 17, minute: 0, second: 0, of: day3)),
            ]
        } else {
            let day1 = weekendStart
            let day2 = cal.date(byAdding: .day, value: 1, to: weekendStart)!
            let day3 = cal.date(byAdding: .day, value: 2, to: weekendStart)!
            // Regular: THU / THU / FRI / FRI / SAT
            return [
                Session(name: "PRACTICE 1", day: "THURSDAY", time: "14:30 - 15:30", isHighlighted: false,
                        startDate: cal.date(bySettingHour: 14, minute: 30, second: 0, of: day1),
                        endDate:   cal.date(bySettingHour: 15, minute: 30, second: 0, of: day1)),
                Session(name: "PRACTICE 2", day: "THURSDAY", time: "18:00 - 19:00", isHighlighted: false,
                        startDate: cal.date(bySettingHour: 18, minute: 0, second: 0, of: day1),
                        endDate:   cal.date(bySettingHour: 19, minute: 0, second: 0, of: day1)),
                Session(name: "PRACTICE 3", day: "FRIDAY",   time: "14:30 - 15:30", isHighlighted: false,
                        startDate: cal.date(bySettingHour: 14, minute: 30, second: 0, of: day2),
                        endDate:   cal.date(bySettingHour: 15, minute: 30, second: 0, of: day2)),
                Session(name: "QUALIFYING", day: "FRIDAY",   time: "18:00 - 19:00", isHighlighted: true,
                        startDate: cal.date(bySettingHour: 18, minute: 0, second: 0, of: day2),
                        endDate:   cal.date(bySettingHour: 19, minute: 0, second: 0, of: day2)),
                Session(name: "GRAND PRIX", day: "SATURDAY", time: "18:00",          isHighlighted: true,
                        startDate: cal.date(bySettingHour: 18, minute: 0, second: 0, of: day3),
                        endDate:   cal.date(bySettingHour: 20, minute: 0, second: 0, of: day3)),
            ]
        }
    }

    /// The next upcoming session's start date (for countdown)
    var nextSessionDate: Date? {
        let now = Date()
        return sessions
            .sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }
            .first { ($0.startDate ?? .distantPast) > now }?.startDate
    }

    /// Currently live session (between startDate and endDate)
    var liveSession: Session? {
        sessions
            .sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }
            .first { $0.isLive }
    }

    /// Badge label for the live session (e.g. "FP1" with LIVE indicator)
    var liveSessionBadge: String? {
        guard let live = liveSession else { return nil }
        return sessionBadgeLabel(live.name)
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Race {
    /// Creates a mock race where FP1 is currently live (for SwiftUI previews and testing)
    static var previewLive: Race {
        let now = Date()
        let cal = Calendar.current
        let sessions = [
            Session(name: "PRACTICE 1", day: "THURSDAY", time: "14:30 - 15:30", isHighlighted: false,
                    startDate: cal.date(byAdding: .minute, value: -30, to: now),
                    endDate: cal.date(byAdding: .minute, value: 30, to: now)),
            Session(name: "PRACTICE 2", day: "THURSDAY", time: "18:00 - 19:00", isHighlighted: false,
                    startDate: cal.date(byAdding: .hour, value: 3, to: now),
                    endDate: cal.date(byAdding: .hour, value: 4, to: now)),
            Session(name: "PRACTICE 3", day: "FRIDAY", time: "14:30 - 15:30", isHighlighted: false,
                    startDate: cal.date(byAdding: .day, value: 1, to: now),
                    endDate: cal.date(byAdding: .hour, value: 25, to: now)),
            Session(name: "QUALIFYING", day: "FRIDAY", time: "18:00 - 19:00", isHighlighted: true,
                    startDate: cal.date(byAdding: .hour, value: 27, to: now),
                    endDate: cal.date(byAdding: .hour, value: 28, to: now)),
            Session(name: "GRAND PRIX", day: "SATURDAY", time: "18:00", isHighlighted: true,
                    startDate: cal.date(byAdding: .day, value: 2, to: now),
                    endDate: cal.date(byAdding: .hour, value: 50, to: now)),
        ]
        return Race(
            id: 99, round: 3,
            name: "Japanese Grand Prix", shortName: "JPN", city: "Suzuka",
            circuit: "Suzuka International Racing Course", country: "Japan", countryFlag: "🇯🇵",
            raceDate: cal.date(byAdding: .day, value: 2, to: now)!,
            qualifyingDate: cal.date(byAdding: .day, value: 1, to: now)!,
            weekendStart: now,
            sprint: false,
            apiSessions: sessions
        )
    }
}
#endif
