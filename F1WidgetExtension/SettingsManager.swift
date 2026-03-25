import Foundation
import Combine

enum TemperatureUnit: String, CaseIterable {
    case celsius = "°C"
    case fahrenheit = "°F"
}

final class SettingsManager: ObservableObject {

    static let shared = SettingsManager()

    private let defaults = UserDefaults(suiteName: "group.com.f1calendar.shared") ?? .standard

    // MARK: - Notification Toggles

    @Published var notifyPractice: Bool {
        didSet { defaults.set(notifyPractice, forKey: Keys.notifyPractice) }
    }

    @Published var notifyQualifying: Bool {
        didSet { defaults.set(notifyQualifying, forKey: Keys.notifyQualifying) }
    }

    @Published var notifySprint: Bool {
        didSet { defaults.set(notifySprint, forKey: Keys.notifySprint) }
    }

    @Published var notifyRace: Bool {
        didSet { defaults.set(notifyRace, forKey: Keys.notifyRace) }
    }

    // MARK: - Reminder Time

    @Published var reminderMinutes: Int {
        didSet { defaults.set(reminderMinutes, forKey: Keys.reminderMinutes) }
    }

    static let reminderOptions = [15, 30, 60, 120]

    // MARK: - Weather

    @Published var weatherApiKey: String {
        didSet { defaults.set(weatherApiKey, forKey: Keys.weatherApiKey) }
    }

    @Published var temperatureUnit: TemperatureUnit {
        didSet { defaults.set(temperatureUnit.rawValue, forKey: Keys.temperatureUnit) }
    }

    // MARK: - Init

    private init() {
        let d = UserDefaults(suiteName: "group.com.f1calendar.shared") ?? .standard

        self.notifyPractice = d.object(forKey: Keys.notifyPractice) as? Bool ?? false
        self.notifyQualifying = d.object(forKey: Keys.notifyQualifying) as? Bool ?? true
        self.notifySprint = d.object(forKey: Keys.notifySprint) as? Bool ?? true
        self.notifyRace = d.object(forKey: Keys.notifyRace) as? Bool ?? true
        self.reminderMinutes = d.object(forKey: Keys.reminderMinutes) as? Int ?? 30
        self.weatherApiKey = d.string(forKey: Keys.weatherApiKey) ?? ""
        let unitRaw = d.string(forKey: Keys.temperatureUnit) ?? TemperatureUnit.celsius.rawValue
        self.temperatureUnit = TemperatureUnit(rawValue: unitRaw) ?? .celsius
    }

    // MARK: - Keys

    private enum Keys {
        static let notifyPractice = "settings.notifyPractice"
        static let notifyQualifying = "settings.notifyQualifying"
        static let notifySprint = "settings.notifySprint"
        static let notifyRace = "settings.notifyRace"
        static let reminderMinutes = "settings.reminderMinutes"
        static let weatherApiKey = "settings.weatherApiKey"
        static let temperatureUnit = "settings.temperatureUnit"
    }
}
