import Foundation

enum WeatherCondition: String, Codable {
    case clear, cloudy, rain, thunderstorm, snow, fog, drizzle

    var lottieFileName: String {
        "weather_\(rawValue)"
    }
}

struct DayForecast: Codable, Identifiable {
    let id: String           // "FRI", "SAT", "SUN"
    let dayLabel: String     // "FRI", "SAT", "SUN"
    let tempHigh: Int        // celsius
    let tempLow: Int         // celsius
    let condition: WeatherCondition
    let trackTemp: Int       // celsius
    let windSpeed: Int       // km/h
    let windDir: String      // SE (compass points)
    let rainChance: Int      // percentage 0-100
}
