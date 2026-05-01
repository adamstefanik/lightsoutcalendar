import Foundation

class WeatherService {
    static let shared = WeatherService()

    private let defaults = UserDefaults(suiteName: "group.com.lightsoutcalendar.shared") ?? .standard

    private let cacheDuration: TimeInterval = 3 * 3600 // 3 hours

    private static var apiKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String, !key.isEmpty, !key.contains("$") {
            return key
        }
        return ""
    }

    private init() {}

    func fetchForecast(latitude: Double, longitude: Double, weekendStart: Date, raceDate: Date, sessions: [Session] = []) async -> [DayForecast] {
        let circuitKey = "\(Int(latitude * 100))_\(Int(longitude * 100))"

        if let cached = loadFromCache(circuitKey: circuitKey) {
            print("[Weather] cache hit \(circuitKey)")
            return cached
        }

        print("[Weather] fetching OWM \(circuitKey) key=\(Self.apiKey.isEmpty ? "MISSING" : "ok")")

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 15
        let session = URLSession(configuration: config)

        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(Self.apiKey)&units=metric"
        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                print("[Weather] OWM status \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return []
            }
            print("[Weather] OWM ok, parsing...")
            var forecasts = try parseForecasts(from: data, weekendStart: weekendStart, raceDate: raceDate)
            print("[Weather] parsed \(forecasts.count) days")

            // Enrich completed days with real OpenF1 weather data
            forecasts = await enrichWithOpenF1(forecasts: forecasts, sessions: sessions)

            if !forecasts.isEmpty {
                saveToCache(forecasts, circuitKey: circuitKey)
            }
            return forecasts
        } catch {
            print("[Weather] error: \(error)")
            return []
        }
    }

    // MARK: - OpenF1 Weather Enrichment

    private struct OpenF1WeatherReading: Decodable {
        let air_temperature: Double?
        let track_temperature: Double?
        let wind_speed: Double?
        let wind_direction: Int?
    }

    private func enrichWithOpenF1(forecasts: [DayForecast], sessions: [Session]) async -> [DayForecast] {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        dayFormatter.timeZone = TimeZone(identifier: "UTC")

        var result = forecasts

        for (index, forecast) in forecasts.enumerated() {
            // Find completed sessions for this day label
            let completedSessionsForDay = sessions.filter { session in
                guard let key = session.sessionKey, let end = session.endDate, let start = session.startDate else { return false }
                let dayLabel = dayFormatter.string(from: start)
                let sessionShortDay = shortDay(from: dayLabel)
                return end < Date() && sessionShortDay == forecast.dayLabel && key > 0
            }

            guard let session = completedSessionsForDay.first,
                  let sessionKey = session.sessionKey else { continue }

            if let openF1Data = await fetchOpenF1Weather(sessionKey: sessionKey) {
                result[index].trackTemp = openF1Data.trackTemp
                result[index].windSpeed = openF1Data.windSpeed
                result[index].windDir = openF1Data.windDir
                result[index].isTrackTempEstimated = false
            }
        }

        return result
    }

    private struct OpenF1WeatherData {
        let trackTemp: Int
        let windSpeed: Int
        let windDir: String
    }

    private func fetchOpenF1Weather(sessionKey: Int) async -> OpenF1WeatherData? {
        guard let url = URL(string: "https://api.openf1.org/v1/weather?session_key=\(sessionKey)") else { return nil }

        for attempt in 1...2 {
            do {
                let (data, resp) = try await URLSession.shared.data(from: url)
                guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
                    if (resp as? HTTPURLResponse)?.statusCode == 429 && attempt == 1 {
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                        continue
                    }
                    return nil
                }

                let readings = try JSONDecoder().decode([OpenF1WeatherReading].self, from: data)
                guard !readings.isEmpty else { return nil }

                let trackTemps = readings.compactMap(\.track_temperature)
                let windSpeeds = readings.compactMap(\.wind_speed)
                let windDirs = readings.compactMap(\.wind_direction)

                guard !trackTemps.isEmpty else { return nil }

                let avgTrackTemp = Int(trackTemps.reduce(0, +) / Double(trackTemps.count))
                let avgWindSpeedKmh = windSpeeds.isEmpty ? 0 : Int((windSpeeds.reduce(0, +) / Double(windSpeeds.count)) * 3.6)
                let avgWindDir = windDirs.isEmpty ? "N" : circularMeanCompass(degrees: windDirs)

                return OpenF1WeatherData(trackTemp: avgTrackTemp, windSpeed: avgWindSpeedKmh, windDir: avgWindDir)
            } catch {
                return nil
            }
        }
        return nil
    }

    private func circularMeanCompass(degrees: [Int]) -> String {
        let radians = degrees.map { Double($0) * .pi / 180 }
        let sinMean = radians.map { sin($0) }.reduce(0, +) / Double(radians.count)
        let cosMean = radians.map { cos($0) }.reduce(0, +) / Double(radians.count)
        var meanDeg = atan2(sinMean, cosMean) * 180 / .pi
        if meanDeg < 0 { meanDeg += 360 }
        return degreesToCompass(Int(meanDeg))
    }

    private func degreesToCompass(_ deg: Int) -> String {
        let dirs = ["N","NNE","NE","ENE","E","ESE","SE","SSE",
                    "S","SSW","SW","WSW","W","WNW","NW","NNW"]
        return dirs[Int((Double(deg) + 11.25) / 22.5) % 16]
    }

    private func shortDay(from dayKey: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        guard let date = f.date(from: dayKey) else { return "" }
        let sf = DateFormatter()
        sf.dateFormat = "EEE"
        sf.locale = Locale(identifier: "en_US_POSIX")
        sf.timeZone = TimeZone(identifier: "UTC")
        return sf.string(from: date).uppercased()
    }

    // MARK: - Cache

    private func loadFromCache(circuitKey: String) -> [DayForecast]? {
        let dataKey = "weatherData_v6_\(circuitKey)"
        let tsKey = "weatherTS_v6_\(circuitKey)"
        guard
            let timestamp = defaults.object(forKey: tsKey) as? Date,
            Date().timeIntervalSince(timestamp) < cacheDuration,
            let data = defaults.data(forKey: dataKey),
            let forecasts = try? JSONDecoder().decode([DayForecast].self, from: data)
        else {
            return nil
        }
        return forecasts
    }

    private func saveToCache(_ forecasts: [DayForecast], circuitKey: String) {
        let dataKey = "weatherData_v6_\(circuitKey)"
        let tsKey = "weatherTS_v6_\(circuitKey)"
        guard let data = try? JSONEncoder().encode(forecasts) else { return }
        defaults.set(data, forKey: dataKey)
        defaults.set(Date(), forKey: tsKey)
    }

    // MARK: - OWM Parsing

    private func parseForecasts(from data: Data, weekendStart: Date, raceDate: Date) throws -> [DayForecast] {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let list = json?["list"] as? [[String: Any]] else { return [] }

        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "UTC")!
        let startDay = cal.startOfDay(for: weekendStart)
        let endDay = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: raceDate))!

        var grouped: [String: [(temp: Double, condition: String, pop: Double, windSpeed: Double, windDeg: Int)]] = [:]

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        dayFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayFormatter.timeZone = TimeZone(identifier: "UTC")

        let shortDayFormatter = DateFormatter()
        shortDayFormatter.dateFormat = "EEE"
        shortDayFormatter.locale = Locale(identifier: "en_US_POSIX")
        shortDayFormatter.timeZone = TimeZone(identifier: "UTC")

        for item in list {
            guard
                let dtTxt = item["dt_txt"] as? String,
                let date = formatter.date(from: dtTxt),
                let main = item["main"] as? [String: Any],
                let temp = main["temp"] as? Double,
                let weatherArr = item["weather"] as? [[String: Any]],
                let conditionStr = weatherArr.first?["main"] as? String
            else { continue }

            guard date >= startDay && date < endDay else { continue }

            let pop = (item["pop"] as? Double) ?? 0.0
            let windObj = item["wind"] as? [String: Any]
            let windSpeedMS = (windObj?["speed"] as? Double) ?? 0.0
            let windDeg = (windObj?["deg"] as? Int) ?? 0

            let dayKey = dayFormatter.string(from: date)
            grouped[dayKey, default: []].append((temp, conditionStr, pop, windSpeedMS, windDeg))
        }

        let sortedKeys = grouped.keys.sorted()
        var result: [DayForecast] = []

        for dayKey in sortedKeys {
            guard
                let intervals = grouped[dayKey],
                let date = dayFormatter.date(from: dayKey)
            else { continue }

            let temps = intervals.map(\.temp)
            let tempHigh = Int(temps.max() ?? 0)
            let tempLow = Int(temps.min() ?? 0)
            let maxRainChance = Int((intervals.map(\.pop).max() ?? 0) * 100)

            var conditionCounts: [String: Int] = [:]
            for interval in intervals { conditionCounts[interval.condition, default: 0] += 1 }
            let dominantConditionStr = conditionCounts.max(by: { $0.value < $1.value })?.key ?? "Clouds"
            let condition = mapCondition(dominantConditionStr)

            // Wind from OWM
            let avgWindSpeedKmh = Int((intervals.map(\.windSpeed).reduce(0, +) / Double(intervals.count)) * 3.6)
            let avgWindDir = degreesToCompass(intervals.map(\.windDeg).reduce(0, +) / intervals.count)

            // Estimated track temp
            let estimatedTrackTemp: Int
            switch condition {
            case .clear:
                estimatedTrackTemp = tempHigh + 10
            case .rain, .thunderstorm, .drizzle:
                estimatedTrackTemp = tempHigh + 2
            default:
                estimatedTrackTemp = tempHigh + 5
            }

            let dayLabel = shortDayFormatter.string(from: date).uppercased()

            result.append(DayForecast(
                id: dayLabel,
                dayLabel: dayLabel,
                tempHigh: tempHigh,
                tempLow: tempLow,
                condition: condition,
                rainChance: maxRainChance,
                trackTemp: estimatedTrackTemp,
                windSpeed: avgWindSpeedKmh,
                windDir: avgWindDir,
                isTrackTempEstimated: true
            ))
        }

        return result
    }

    // MARK: - Condition mapping

    private func mapCondition(_ main: String) -> WeatherCondition {
        switch main {
        case "Clear":                    return .clear
        case "Clouds":                   return .cloudy
        case "Rain":                     return .rain
        case "Thunderstorm":             return .thunderstorm
        case "Snow":                     return .snow
        case "Fog", "Mist", "Haze":     return .fog
        case "Drizzle":                  return .drizzle
        default:                         return .cloudy
        }
    }
}
