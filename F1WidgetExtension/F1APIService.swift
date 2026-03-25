import Foundation

// MARK: - OpenF1 API Response Models

struct OpenF1Meeting: Codable {
    let meeting_key: Int
    let meeting_name: String
    let meeting_official_name: String
    let location: String
    let country_code: String
    let country_name: String
    let circuit_short_name: String
    let date_start: String
    let date_end: String
    let year: Int
}

struct OpenF1Session: Codable {
    let session_key: Int
    let session_type: String
    let session_name: String
    let date_start: String
    let date_end: String
    let meeting_key: Int
    let country_code: String
    let country_name: String
    let location: String
    let year: Int
}

// MARK: - API Service

final class F1APIService {

    static let shared = F1APIService()

    private let baseURL = "https://api.openf1.org/v1"
    private let cacheKey = "F1CachedRaces"
    private let cacheTimestampKey = "F1CacheTimestamp"
    private let cacheDuration: TimeInterval = 6 * 3600

    private let defaults = UserDefaults(suiteName: "group.com.f1calendar.shared") ?? .standard

    private lazy var isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private lazy var timeDisplayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = .current
        return f
    }()

    private lazy var dayOfWeekFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        f.locale = Locale(identifier: "en_US")
        return f
    }()

    // MARK: - Public

    func fetchRaces(season: Int = 2026) async -> [Race] {
        if let cached = loadCachedRaces(), isCacheValid() {
            print("[F1API] Using cached races (\(cached.count))")
            return cached
        }
        print("[F1API] Fetching from API...")
        if let apiRaces = await fetchFromAPI(season: season), !apiRaces.isEmpty {
            print("[F1API] Got \(apiRaces.count) races from API")
            cacheRaces(apiRaces)
            return apiRaces
        }
        if let cached = loadCachedRaces() {
            print("[F1API] Using expired cache (\(cached.count))")
            return cached
        }
        print("[F1API] Using fallback data")
        return F1Calendar.fallbackRaces
    }

    // MARK: - Network

    private func fetchFromAPI(season: Int) async -> [Race]? {
        guard let meetingsURL = URL(string: "\(baseURL)/meetings?year=\(season)"),
              let sessionsURL = URL(string: "\(baseURL)/sessions?year=\(season)") else { return nil }

        do {
            async let meetingsData = URLSession.shared.data(from: meetingsURL)
            async let sessionsData = URLSession.shared.data(from: sessionsURL)

            let (mData, mResponse) = try await meetingsData
            let (sData, sResponse) = try await sessionsData

            guard let mHttp = mResponse as? HTTPURLResponse, mHttp.statusCode == 200,
                  let sHttp = sResponse as? HTTPURLResponse, sHttp.statusCode == 200 else { return nil }

            let meetings = try JSONDecoder().decode([OpenF1Meeting].self, from: mData)
            let sessions = try JSONDecoder().decode([OpenF1Session].self, from: sData)

            // Group sessions by meeting_key
            let sessionsByMeeting = Dictionary(grouping: sessions, by: \.meeting_key)

            // Filter out pre-season testing, keep only GPs
            let gpMeetings = meetings.filter { $0.meeting_name.contains("Grand Prix") }

            return gpMeetings.enumerated().compactMap { index, meeting in
                let meetingSessions = sessionsByMeeting[meeting.meeting_key] ?? []
                return self.convertToRace(meeting: meeting, sessions: meetingSessions, index: index)
            }
        } catch {
            print("[F1API] Error: \(error)")
            return nil
        }
    }

    // MARK: - Conversion

    private func convertToRace(meeting: OpenF1Meeting, sessions: [OpenF1Session], index: Int) -> Race {
        let sortedSessions = sessions.sorted { $0.date_start < $1.date_start }

        let raceSession = sortedSessions.first { $0.session_type == "Race" }
        let qualSession = sortedSessions.first { $0.session_type == "Qualifying" }
        let fp1Session = sortedSessions.first { $0.session_type == "Practice" }
        let sprintSession = sortedSessions.first { $0.session_type == "Sprint" }
        let isSprint = sprintSession != nil

        let raceDate = parseDate(raceSession?.date_start ?? meeting.date_end)
        let qualDate = parseDate(qualSession?.date_start ?? meeting.date_end)
        let weekendStart = parseDate(fp1Session?.date_start ?? meeting.date_start)

        let country = meeting.country_name
        let shortName = Self.countryShortNames[meeting.country_code] ?? meeting.country_code
        let flag = Self.countryFlags[meeting.country_code] ?? "🏁"

        let widgetSessions = buildSessions(from: sortedSessions, isSprint: isSprint)

        return Race(
            id: index + 1,
            round: index + 1,
            name: meeting.meeting_name,
            shortName: shortName,
            city: meeting.location,
            circuit: meeting.circuit_short_name,
            country: country,
            countryFlag: flag,
            raceDate: raceDate,
            qualifyingDate: qualDate,
            weekendStart: weekendStart,
            sprint: isSprint,
            apiSessions: widgetSessions.isEmpty ? nil : widgetSessions
        )
    }

    private func buildSessions(from apiSessions: [OpenF1Session], isSprint: Bool) -> [Session] {
        var result: [Session] = []

        for api in apiSessions {
            let startDate = parseDate(api.date_start)
            let endDate = parseDate(api.date_end)
            let day = dayOfWeekFormatter.string(from: startDate).uppercased()
            let startTime = timeDisplayFormatter.string(from: startDate)
            let endTime = timeDisplayFormatter.string(from: endDate)

            let name: String
            let highlighted: Bool
            let timeStr: String

            switch api.session_type {
            case "Practice":
                name = api.session_name.uppercased()
                    .replacingOccurrences(of: "PRACTICE", with: "PRACTICE")
                highlighted = false
                timeStr = "\(startTime) - \(endTime)"

            case "Qualifying":
                name = "QUALIFYING"
                highlighted = !isSprint
                timeStr = "\(startTime) - \(endTime)"

            case "Sprint Qualifying", "Sprint Shootout":
                name = "SPRINT QUALI"
                highlighted = true
                timeStr = "\(startTime) - \(endTime)"

            case "Sprint":
                name = "SPRINT"
                highlighted = true
                timeStr = "\(startTime) - \(endTime)"

            case "Race":
                name = "GRAND PRIX"
                highlighted = true
                timeStr = startTime

            default:
                continue
            }

            result.append(Session(
                name: name,
                day: day,
                time: timeStr,
                isHighlighted: highlighted,
                startDate: startDate
            ))
        }

        return result
    }

    private func parseDate(_ str: String) -> Date {
        if let d = isoFormatter.date(from: str) { return d }
        return Date()
    }

    // MARK: - Cache

    private func isCacheValid() -> Bool {
        let timestamp = defaults.double(forKey: cacheTimestampKey)
        guard timestamp > 0 else { return false }
        return Date().timeIntervalSince1970 - timestamp < cacheDuration
    }

    private func cacheRaces(_ races: [Race]) {
        if let data = try? JSONEncoder().encode(races) {
            defaults.set(data, forKey: cacheKey)
            defaults.set(Date().timeIntervalSince1970, forKey: cacheTimestampKey)
        }
    }

    private func loadCachedRaces() -> [Race]? {
        guard let data = defaults.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode([Race].self, from: data)
    }

    // MARK: - Lookup Tables

    private static let countryFlags: [String: String] = [
        "AUS": "🇦🇺", "CHN": "🇨🇳", "JPN": "🇯🇵", "BHR": "🇧🇭",
        "SAU": "🇸🇦", "USA": "🇺🇸", "ITA": "🇮🇹", "MCO": "🇲🇨",
        "ESP": "🇪🇸", "CAN": "🇨🇦", "AUT": "🇦🇹", "GBR": "🇬🇧",
        "BEL": "🇧🇪", "NLD": "🇳🇱", "AZE": "🇦🇿", "SGP": "🇸🇬",
        "MEX": "🇲🇽", "BRA": "🇧🇷", "QAT": "🇶🇦", "ARE": "🇦🇪",
    ]

    private static let countryShortNames: [String: String] = [
        "AUS": "AUS", "CHN": "CHN", "JPN": "JPN", "BHR": "BHR",
        "SAU": "SAU", "USA": "USA", "ITA": "ITA", "MCO": "MON",
        "ESP": "ESP", "CAN": "CAN", "AUT": "AUT", "GBR": "GBR",
        "BEL": "BEL", "NLD": "NED", "AZE": "AZE", "SGP": "SGP",
        "MEX": "MEX", "BRA": "BRA", "QAT": "QAT", "ARE": "ABU",
    ]
}
