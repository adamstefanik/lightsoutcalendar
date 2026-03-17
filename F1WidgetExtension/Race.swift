import Foundation

struct Session: Codable {
    let name: String
    let day: String
    let time: String
    let isHighlighted: Bool
    let startDate: Date?

    init(name: String, day: String, time: String, isHighlighted: Bool, startDate: Date? = nil) {
        self.name = name
        self.day = day
        self.time = time
        self.isHighlighted = isHighlighted
        self.startDate = startDate
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
    let apiSessions: [Session]?

    init(id: Int, round: Int, name: String, shortName: String, city: String,
         circuit: String, country: String, countryFlag: String,
         raceDate: Date, qualifyingDate: Date, weekendStart: Date,
         sprint: Bool, apiSessions: [Session]? = nil) {
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
        self.apiSessions = apiSessions
    }

    var isCompleted: Bool { raceDate < Date() }

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
        if let apiSessions = apiSessions {
            let now = Date()
            // Find the next upcoming session
            for session in apiSessions.reversed() {
                if let start = session.startDate, start <= now {
                    return sessionBadgeLabel(session.name)
                }
            }
            return "FP1"
        }
        let now = Date()
        if raceDate <= now { return "RACE" }
        if qualifyingDate <= now { return "QUAL" }
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
        // Fallback to hardcoded sessions
        if sprint {
            return [
                Session(name: "PRACTICE 1",   day: "FRIDAY",   time: "13:30 - 14:30", isHighlighted: false),
                Session(name: "SPRINT QUALI", day: "FRIDAY",   time: "17:30 - 18:30", isHighlighted: true),
                Session(name: "SPRINT",       day: "SATURDAY", time: "12:00 - 13:00", isHighlighted: true),
                Session(name: "QUALIFYING",   day: "SATURDAY", time: "16:00 - 17:00", isHighlighted: false),
                Session(name: "GRAND PRIX",   day: "SUNDAY",   time: "15:00",          isHighlighted: true),
            ]
        } else {
            return [
                Session(name: "PRACTICE 1", day: "THURSDAY", time: "14:30 - 15:30", isHighlighted: false),
                Session(name: "PRACTICE 2", day: "THURSDAY", time: "18:00 - 19:00", isHighlighted: false),
                Session(name: "PRACTICE 3", day: "FRIDAY",   time: "14:30 - 15:30", isHighlighted: false),
                Session(name: "QUALIFYING", day: "FRIDAY",   time: "18:00 - 19:00", isHighlighted: true),
                Session(name: "GRAND PRIX", day: "SATURDAY", time: "18:00",          isHighlighted: true),
            ]
        }
    }
}
