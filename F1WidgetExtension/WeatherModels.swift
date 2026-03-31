import Foundation

enum WeatherCondition: String, Codable {
    case clear, cloudy, rain, thunderstorm, snow, fog, drizzle

    var lottieFileName: String {
        "weather_\(rawValue)"
    }
}

struct DayForecast: Codable, Identifiable {
    let id: String                      // "FRI", "SAT", "SUN"
    let dayLabel: String                // "FRI", "SAT", "SUN"
    let tempHigh: Int                   // celsius
    let tempLow: Int                    // celsius
    let condition: WeatherCondition
    let rainChance: Int                 // percentage 0-100
    var trackTemp: Int? = nil           // celsius, nil = not available
    var windSpeed: Int? = nil           // km/h, nil = not available
    var windDir: String? = nil          // "SE" etc., nil = not available
    var isTrackTempEstimated: Bool = false  // true = estimated from air temp
}
