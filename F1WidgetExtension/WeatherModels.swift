import Foundation

enum WeatherCondition: String, Codable {
    case clear, cloudy, rain, thunderstorm, snow, fog, drizzle

    var emoji: String {
        switch self {
        case .clear: return "☀️"
        case .cloudy: return "☁️"
        case .rain: return "🌧️"
        case .thunderstorm: return "⛈️"
        case .snow: return "❄️"
        case .fog: return "🌫️"
        case .drizzle: return "🌦️"
        }
    }

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
    let rainChance: Int      // percentage 0-100
}
