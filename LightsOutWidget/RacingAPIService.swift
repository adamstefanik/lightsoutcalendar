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

struct OpenF1Position: Codable {
    let driver_number: Int
    let position: Int?
    let date: String?
}

struct OpenF1Driver: Codable {
    let driver_number: Int
    let first_name: String
    let last_name: String
    let team_name: String?
    let name_acronym: String?
}

struct OpenF1Lap: Codable {
    let driver_number: Int
    let lap_number: Int
    let lap_duration: Double?
    let is_pit_out_lap: Bool
    let date_start: String?
}

struct OpenF1Stint: Codable {
    let driver_number: Int
    let lap_start: Int
    let lap_end: Int
    let compound: String?
}


// MARK: - API Service

final class F1APIService {

    static let shared = F1APIService()

    private let baseURL = "https://api.openf1.org/v1"
    private let cacheKey = "F1CachedRaces_v4"
    private let cacheTimestampKey = "F1CacheTimestamp_v4"
    private let cacheDuration: TimeInterval = 6 * 3600

    private let defaults = UserDefaults(suiteName: "group.com.lightsoutcalendar.shared") ?? .standard

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
                  let sHttp = sResponse as? HTTPURLResponse, sHttp.statusCode == 200 else {
                let mCode = (mResponse as? HTTPURLResponse)?.statusCode ?? -1
                let sCode = (sResponse as? HTTPURLResponse)?.statusCode ?? -1
                print("[F1API] API returned status \(mCode)/\(sCode)")
                return nil
            }

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

        let raceSession = sortedSessions.last { $0.session_type == "Race" }
        let qualSession = sortedSessions.first { $0.session_type == "Qualifying" }
        let fp1Session = sortedSessions.first { $0.session_type == "Practice" }
        let isSprint = sortedSessions.contains { $0.session_name.lowercased().contains("sprint") }

        let raceDate = parseDate(raceSession?.date_start ?? meeting.date_end)
        let qualDate = parseDate(qualSession?.date_start ?? meeting.date_end)
        let weekendStart = parseDate(fp1Session?.date_start ?? meeting.date_start)

        let country = meeting.country_name
        let shortName = Self.countryShortNames[meeting.country_code] ?? meeting.country_code
        let flag = Self.countryFlags[meeting.country_code] ?? "🏁"
        let canceled = Self.canceledRaces.contains(meeting.country_code)

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
            isCanceled: canceled,
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
                highlighted = false
                timeStr = "\(startTime) - \(endTime)"

            case "Qualifying":
                if api.session_name.lowercased().contains("sprint") {
                    name = "SPRINT QUALI"
                    highlighted = true
                } else {
                    name = "QUALIFYING"
                    highlighted = !isSprint
                }
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
                if api.session_name.lowercased().contains("sprint") {
                    name = "SPRINT"
                    highlighted = true
                    timeStr = "\(startTime) - \(endTime)"
                } else {
                    name = "GRAND PRIX"
                    highlighted = true
                    timeStr = startTime
                }

            default:
                continue
            }

            result.append(Session(
                name: name,
                day: day,
                time: timeStr,
                isHighlighted: highlighted,
                startDate: startDate,
                endDate: endDate,
                sessionKey: api.session_key
            ))
        }

        return result
    }

    private func parseDate(_ str: String) -> Date {
        if let d = isoFormatter.date(from: str) { return d }
        print("[F1API] Failed to parse date: \(str)")
        return .distantPast
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

    static let countryFlags: [String: String] = [
        "AUS": "🇦🇺", "CHN": "🇨🇳", "JPN": "🇯🇵", "BRN": "🇧🇭",
        "KSA": "🇸🇦", "USA": "🇺🇸", "ITA": "🇮🇹", "MCO": "🇲🇨",
        "ESP": "🇪🇸", "CAN": "🇨🇦", "AUT": "🇦🇹", "GBR": "🇬🇧",
        "BEL": "🇧🇪", "NLD": "🇳🇱", "AZE": "🇦🇿", "SGP": "🇸🇬",
        "MEX": "🇲🇽", "BRA": "🇧🇷", "QAT": "🇶🇦", "ARE": "🇦🇪",
        "UAE": "🇦🇪", "HUN": "🇭🇺", "NED": "🇳🇱", "MON": "🇲🇨",
    ]

    private static let countryShortNames: [String: String] = [
        "AUS": "AUS", "CHN": "CHN", "JPN": "JPN", "BRN": "BHR",
        "KSA": "SAU", "USA": "USA", "ITA": "ITA", "MCO": "MON",
        "ESP": "ESP", "CAN": "CAN", "AUT": "AUT", "GBR": "GBR",
        "BEL": "BEL", "NLD": "NED", "AZE": "AZE", "SGP": "SGP",
        "MEX": "MEX", "BRA": "BRA", "QAT": "QAT", "ARE": "ABU",
        "UAE": "ABU", "HUN": "HUN", "NED": "NED", "MON": "MON",
    ]

    private static let canceledRaces: Set<String> = ["BRN", "KSA"]

    // Use team name exactly as returned by upstream API to avoid adding
    // sponsor/commercial trademarks ourselves.
    private static let fullTeamNames: [String: String] = [:]

    // MARK: - Race Results

    private let resultsCacheKey = "F1CachedResults_v18"
    private let resultsCacheTimestampKey = "F1ResultsCacheTimestamp_v18"

    enum SessionType {
        case race, sprint, timing, sprintTiming, practice
    }

    func fetchResults(for sessionKey: Int, sessionType: SessionType = .race) async -> [DriverResult] {
        // Check cache
        let cacheKey = "\(resultsCacheKey)_\(sessionKey)"
        let timestampKey = "\(resultsCacheTimestampKey)_\(sessionKey)"

        if let cached = loadCachedResults(cacheKey: cacheKey),
           isResultsCacheValid(timestampKey: timestampKey) {
            return cached
        }

        // Fetch from OpenF1
        guard let positionsURL = URL(string: "\(baseURL)/position?session_key=\(sessionKey)&position<=20"),
              let driversURL = URL(string: "\(baseURL)/drivers?session_key=\(sessionKey)"),
              let lapsURL = URL(string: "\(baseURL)/laps?session_key=\(sessionKey)"),
              let stintsURL = URL(string: "\(baseURL)/stints?session_key=\(sessionKey)") else {
            return []
        }

        do {
            async let posData = URLSession.shared.data(from: positionsURL)
            async let drvData = URLSession.shared.data(from: driversURL)
            async let lapData = URLSession.shared.data(from: lapsURL)

            let (pData, pResp) = try await posData
            let (dData, dResp) = try await drvData
            let (lData, lResp) = try await lapData

            guard let pH = pResp as? HTTPURLResponse, pH.statusCode == 200,
                  let dH = dResp as? HTTPURLResponse, dH.statusCode == 200,
                  let lH = lResp as? HTTPURLResponse, lH.statusCode == 200 else { return [] }

            let positions = try JSONDecoder().decode([OpenF1Position].self, from: pData)
            let drivers = try JSONDecoder().decode([OpenF1Driver].self, from: dData)
            let laps = try JSONDecoder().decode([OpenF1Lap].self, from: lData)
            let driverMap = Dictionary(grouping: drivers, by: \.driver_number)
            let lapsByDriver = Dictionary(grouping: laps, by: \.driver_number)

            // Stints — fetch after main data to avoid rate limiting
            let stintsByDriver: [Int: [OpenF1Stint]]
            if sessionType == .timing || sessionType == .sprintTiming {
                stintsByDriver = await fetchStints(url: stintsURL)
            } else {
                stintsByDriver = [:]
            }

            let results: [DriverResult]
            switch sessionType {
            case .timing:
                results = buildTimingResults(positions: positions, drivers: driverMap, lapsByDriver: lapsByDriver, stintsByDriver: stintsByDriver, showDeltas: false, segmentPrefix: "Q")
            case .sprintTiming:
                results = buildTimingResults(positions: positions, drivers: driverMap, lapsByDriver: lapsByDriver, stintsByDriver: stintsByDriver, showDeltas: false, segmentPrefix: "SQ")
            case .practice:
                results = buildTimingResults(positions: positions, drivers: driverMap, lapsByDriver: lapsByDriver, stintsByDriver: [:], showDeltas: true, segmentPrefix: nil)
            case .race, .sprint:
                results = buildRaceResults(positions: positions, drivers: driverMap, lapsByDriver: lapsByDriver, isSprint: sessionType == .sprint)
            }

            if !results.isEmpty {
                cacheResults(results, cacheKey: cacheKey, timestampKey: timestampKey)
            }
            return results
        } catch {
            print("[F1API] Results error: \(error)")
            return []
        }
    }

    private func fetchStints(url: URL) async -> [Int: [OpenF1Stint]] {
        for attempt in 1...2 {
            do {
                let (data, resp) = try await URLSession.shared.data(from: url)
                if let http = resp as? HTTPURLResponse {
                    if http.statusCode == 200 {
                        let stints = try JSONDecoder().decode([OpenF1Stint].self, from: data)
                        print("[F1API] Stints loaded: \(stints.count) for session")
                        return Dictionary(grouping: stints, by: \.driver_number)
                    } else if http.statusCode == 429 && attempt == 1 {
                        print("[F1API] Stints rate limited, retrying...")
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                        continue
                    }
                }
                return [:]
            } catch {
                print("[F1API] Stints fetch error: \(error)")
                return [:]
            }
        }
        return [:]
    }

    // MARK: - Timing Results (Practice, Qualifying, Sprint Quali)

    private func buildTimingResults(positions: [OpenF1Position], drivers: [Int: [OpenF1Driver]], lapsByDriver: [Int: [OpenF1Lap]], stintsByDriver: [Int: [OpenF1Stint]], showDeltas: Bool = false, segmentPrefix: String? = nil) -> [DriverResult] {
        // Get fastest lap per driver (lap number + duration)
        var driverFastestLaps: [Int: Double] = [:]
        var driverFastestLapNumbers: [Int: Int] = [:]
        for (driverNum, driverLaps) in lapsByDriver {
            let validLaps = driverLaps.filter { $0.lap_duration != nil && !$0.is_pit_out_lap }
            if let fastestLap = validLaps.min(by: { $0.lap_duration! < $1.lap_duration! }) {
                driverFastestLaps[driverNum] = fastestLap.lap_duration!
                driverFastestLapNumbers[driverNum] = fastestLap.lap_number
            }
        }

        // Sort by fastest lap time
        let sorted = driverFastestLaps.sorted { $0.value < $1.value }
        let p1Time = sorted.first?.value

        var results: [DriverResult] = []

        for (index, item) in sorted.enumerated() {
            guard let driver = drivers[item.key]?.first else { continue }
            let fullName = "\(driver.first_name) \(driver.last_name)"
            let position = index + 1

            let time = formatLapTime(item.value)
            let gap: String
            if position > 1, let p1 = p1Time {
                gap = "+\(formatGap(item.value - p1))"
            } else {
                gap = ""
            }

            let segment: String
            if let prefix = segmentPrefix {
                switch position {
                case 1...10: segment = "\(prefix)3"
                case 11...15: segment = "\(prefix)2"
                default: segment = "\(prefix)1"
                }
            } else {
                segment = ""
            }

            let lapCount = lapsByDriver[item.key]?.map(\.lap_number).max() ?? 0

            // Find compound used on fastest lap
            let compound: String
            if let fastestLapNum = driverFastestLapNumbers[item.key],
               let stints = stintsByDriver[item.key] {
                let stint = stints.first { $0.lap_start <= fastestLapNum && $0.lap_end >= fastestLapNum }
                compound = stint?.compound ?? ""
                if position <= 3 {
                    print("[F1API] P\(position) \(fullName): fastest lap \(fastestLapNum), stints=\(stints.count), compound=\(compound)")
                }
            } else {
                compound = ""
                if position <= 3 {
                    print("[F1API] P\(position) \(fullName): no stints data (stintsByDriver has \(stintsByDriver.count) drivers)")
                }
            }

            results.append(DriverResult(
                position: position,
                driverName: fullName,
                team: Self.fullTeamNames[driver.team_name ?? ""] ?? driver.team_name ?? "Unknown",
                time: time,
                gap: gap,
                points: 0,
                fastestLap: position == 1,
                fastestLapTime: position == 1 ? formatLapTime(item.value) : "",
                segment: segment,
                dnf: false,
                laps: lapCount,
                compound: compound
            ))
        }

        // Drivers with no lap time
        let driversWithTime = Set(driverFastestLaps.keys)
        let allDriverNums = Set(drivers.keys)
        let noTimeDrivers = allDriverNums.subtracting(driversWithTime)

        for driverNum in noTimeDrivers {
            guard let driver = drivers[driverNum]?.first else { continue }
            let fullName = "\(driver.first_name) \(driver.last_name)"
            results.append(DriverResult(
                position: results.count + 1,
                driverName: fullName,
                team: Self.fullTeamNames[driver.team_name ?? ""] ?? driver.team_name ?? "Unknown",
                time: "NO TIME",
                gap: "",
                points: 0,
                fastestLap: false,
                fastestLapTime: "",
                segment: "",
                dnf: false,
                laps: 0,
                compound: ""
            ))
        }

        return results
    }

    // MARK: - Race/Sprint Results

    private func buildRaceResults(positions: [OpenF1Position], drivers: [Int: [OpenF1Driver]], lapsByDriver: [Int: [OpenF1Lap]], isSprint: Bool) -> [DriverResult] {
        // Get final positions
        let sortedPositions = positions.sorted { ($0.date ?? "") < ($1.date ?? "") }
        var finalPositions: [Int: OpenF1Position] = [:]
        for pos in sortedPositions {
            if pos.position != nil {
                finalPositions[pos.driver_number] = pos
            }
        }

        // Calculate total race time and fastest lap per driver
        let leaderLapCount = lapsByDriver.values.map { $0.map(\.lap_number).max() ?? 0 }.max() ?? 0
        let dnfThreshold = max(1, leaderLapCount - 5)

        var driverTotalTimes: [Int: Double] = [:]
        var driverFastestLaps: [Int: Double] = [:]

        for (driverNum, driverLaps) in lapsByDriver {
            let sortedLaps = driverLaps.sorted { $0.lap_number < $1.lap_number }
            if let firstDateStr = sortedLaps.first?.date_start,
               let lastDateStr = sortedLaps.last?.date_start,
               let firstDate = parseISODate(firstDateStr),
               let lastDate = parseISODate(lastDateStr) {
                let dateTotal = lastDate.timeIntervalSince(firstDate)
                if dateTotal > 0 { driverTotalTimes[driverNum] = dateTotal }
            }

            let validLaps = driverLaps.filter { $0.lap_duration != nil }
            if let fastest = validLaps.compactMap(\.lap_duration).min() {
                driverFastestLaps[driverNum] = fastest
            }
        }

        let overallFastestDriver = driverFastestLaps.min(by: { $0.value < $1.value })?.key
        let p1Driver = finalPositions.values.first { $0.position == 1 }
        let p1TotalTime = p1Driver.flatMap { driverTotalTimes[$0.driver_number] }

        var finishers: [(pos: OpenF1Position, driver: OpenF1Driver)] = []
        var dnfDrivers: [(pos: OpenF1Position, driver: OpenF1Driver)] = []

        for pos in finalPositions.values {
            guard pos.position != nil,
                  let driver = drivers[pos.driver_number]?.first else { continue }
            let maxLap = lapsByDriver[pos.driver_number]?.map(\.lap_number).max() ?? 0
            if maxLap < dnfThreshold {
                dnfDrivers.append((pos, driver))
            } else {
                finishers.append((pos, driver))
            }
        }

        finishers.sort { ($0.pos.position ?? 99) < ($1.pos.position ?? 99) }
        dnfDrivers.sort { (lapsByDriver[$0.pos.driver_number]?.map(\.lap_number).max() ?? 0) >
                          (lapsByDriver[$1.pos.driver_number]?.map(\.lap_number).max() ?? 0) }

        var results: [DriverResult] = []

        for item in finishers {
            let position = item.pos.position!
            let fullName = "\(item.driver.first_name) \(item.driver.last_name)"

            let time: String
            if position == 1, let total = driverTotalTimes[item.pos.driver_number] {
                time = formatTotalTime(total)
            } else if let p1Time = p1TotalTime, let driverTime = driverTotalTimes[item.pos.driver_number] {
                let gap = driverTime - p1Time
                time = gap > 0 ? "+\(formatGap(gap))" : ""
            } else {
                time = ""
            }

            let isFastestLap = item.pos.driver_number == overallFastestDriver
            let fastestLapTime = isFastestLap ? driverFastestLaps[item.pos.driver_number].map { formatLapTime($0) } ?? "" : ""
            results.append(DriverResult(
                position: position,
                driverName: fullName,
                team: Self.fullTeamNames[item.driver.team_name ?? ""] ?? item.driver.team_name ?? "Unknown",
                time: time,
                gap: "",
                points: pointsForPosition(position, isSprint: isSprint),
                fastestLap: isFastestLap,
                fastestLapTime: fastestLapTime,
                segment: "",
                dnf: false,
                laps: 0,
                compound: ""
            ))
        }

        for (i, item) in dnfDrivers.enumerated() {
            let fullName = "\(item.driver.first_name) \(item.driver.last_name)"
            results.append(DriverResult(
                position: finishers.count + i + 1,
                driverName: fullName,
                team: Self.fullTeamNames[item.driver.team_name ?? ""] ?? item.driver.team_name ?? "Unknown",
                time: "DNF",
                gap: "",
                points: 0,
                fastestLap: false,
                fastestLapTime: "",
                segment: "",
                dnf: true,
                laps: 0,
                compound: ""
            ))
        }

        return results
    }

    private func formatLapTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = seconds - Double(mins * 60)
        return String(format: "%d:%06.3f", mins, secs)
    }

    private func parseISODate(_ str: String) -> Date? {
        // Handle format: 2026-03-08T04:03:26.365000+00:00
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: str)
    }

    private func formatTotalTime(_ seconds: Double) -> String {
        let hrs = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds.truncatingRemainder(dividingBy: 1)) * 1000)
        if hrs > 0 {
            return String(format: "%d:%02d:%02d.%03d", hrs, mins, secs, ms)
        }
        return String(format: "%d:%02d.%03d", mins, secs, ms)
    }

    private func formatGap(_ seconds: Double) -> String {
        if seconds >= 60 {
            let mins = Int(seconds) / 60
            let secs = seconds - Double(mins * 60)
            return String(format: "%dm %05.3fs", mins, secs)
        }
        return String(format: "%.3fs", seconds)
    }

    private func pointsForPosition(_ position: Int, isSprint: Bool = false) -> Int {
        if isSprint {
            switch position {
            case 1: return 8
            case 2: return 7
            case 3: return 6
            case 4: return 5
            case 5: return 4
            case 6: return 3
            case 7: return 2
            case 8: return 1
            default: return 0
            }
        }
        switch position {
        case 1: return 25
        case 2: return 18
        case 3: return 15
        case 4: return 12
        case 5: return 10
        case 6: return 8
        case 7: return 6
        case 8: return 4
        case 9: return 2
        case 10: return 1
        default: return 0
        }
    }

    private func isResultsCacheValid(timestampKey: String) -> Bool {
        let timestamp = defaults.double(forKey: timestampKey)
        guard timestamp > 0 else { return false }
        return Date().timeIntervalSince1970 - timestamp < cacheDuration
    }

    private func cacheResults(_ results: [DriverResult], cacheKey: String, timestampKey: String) {
        if let data = try? JSONEncoder().encode(results) {
            defaults.set(data, forKey: cacheKey)
            defaults.set(Date().timeIntervalSince1970, forKey: timestampKey)
        }
    }

    private func loadCachedResults(cacheKey: String) -> [DriverResult]? {
        guard let data = defaults.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode([DriverResult].self, from: data)
    }
}
