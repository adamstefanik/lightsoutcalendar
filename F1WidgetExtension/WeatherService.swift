import Foundation

class WeatherService {
    static let shared = WeatherService()

    private let defaults = UserDefaults(suiteName: "group.com.f1calendar.shared") ?? .standard

    private let cacheDuration: TimeInterval = 3 * 3600 // 3 hours

    private static var apiKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String, !key.isEmpty, !key.contains("$") {
            return key
        }
        return "37952863ba0801cf314d405d9a4a44a2"
    }

    private init() {}

    func fetchForecast(latitude: Double, longitude: Double, weekendStart: Date, raceDate: Date) async -> [DayForecast] {
        let circuitKey = "\(Int(latitude * 100))_\(Int(longitude * 100))"

        // Check cache first
        if let cached = loadFromCache(circuitKey: circuitKey) {
            return cached
        }

        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(Self.apiKey)&units=metric"
        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return [] }
            let forecasts = try parseForecasts(from: data, weekendStart: weekendStart, raceDate: raceDate)
            saveToCache(forecasts, circuitKey: circuitKey)
            return forecasts
        } catch {
            return []
        }
    }

    // MARK: - Cache

    private func loadFromCache(circuitKey: String) -> [DayForecast]? {
        let dataKey = "weatherData_v4_\(circuitKey)"
        let tsKey = "weatherTS_v4_\(circuitKey)"
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
        let dataKey = "weatherData_v4_\(circuitKey)"
        let tsKey = "weatherTS_v4_\(circuitKey)"
        guard let data = try? JSONEncoder().encode(forecasts) else { return }
        defaults.set(data, forKey: dataKey)
        defaults.set(Date(), forKey: tsKey)
    }

    // MARK: - Parsing

    private func parseForecasts(from data: Data, weekendStart: Date, raceDate: Date) throws -> [DayForecast] {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let list = json?["list"] as? [[String: Any]] else { return [] }

        var cal = Calendar.current
        cal.timeZone = TimeZone(identifier: "UTC")!
        let startDay = cal.startOfDay(for: weekendStart)
        let endDay = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: raceDate))!

        // Group intervals by calendar day (yyyy-MM-dd)
        var grouped: [String: [(temp: Double, condition: String, pop: Double)]] = [:]

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

            // Only include data within race weekend
            guard date >= startDay && date < endDay else { continue }

            let pop = (item["pop"] as? Double) ?? 0.0
            let dayKey = dayFormatter.string(from: date)
            grouped[dayKey, default: []].append((temp: temp, condition: conditionStr, pop: pop))
        }

        // Build sorted DayForecast array for weekend days
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

            // Most frequent weather condition
            var conditionCounts: [String: Int] = [:]
            for interval in intervals {
                conditionCounts[interval.condition, default: 0] += 1
            }
            let dominantConditionStr = conditionCounts.max(by: { $0.value < $1.value })?.key ?? "Clouds"
            let condition = mapCondition(dominantConditionStr)

            let dayLabel = shortDayFormatter.string(from: date).uppercased()

            result.append(DayForecast(
                id: dayLabel,
                dayLabel: dayLabel,
                tempHigh: tempHigh,
                tempLow: tempLow,
                condition: condition,
                rainChance: maxRainChance
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
