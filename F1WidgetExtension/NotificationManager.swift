import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("[Notifications] Permission error: \(error)")
            return false
        }
    }

    // MARK: - Schedule

    func scheduleNotifications(for races: [Race], settings: SettingsManager) {
        cancelAll()

        let reminderInterval = TimeInterval(settings.reminderMinutes * 60)
        let upcomingRaces = races.filter { !$0.isCompleted }.prefix(5)
        for race in upcomingRaces {
            guard let sessions = race.apiSessions ?? Optional(race.sessions) else { continue }

            for session in sessions {
                guard let startDate = session.startDate else { continue }
                guard shouldNotify(session: session, settings: settings) else { continue }

                let fireDate = startDate.addingTimeInterval(-reminderInterval)
                guard fireDate > Date() else { continue }

                let content = UNMutableNotificationContent()
                content.title = race.name
                content.body = "\(session.name) starts in \(reminderLabel(settings.reminderMinutes))"
                content.sound = .default

                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                let id = "f1_\(race.id)_\(session.name.replacingOccurrences(of: " ", with: "_"))"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                center.add(request) { error in
                    if let error = error {
                        print("[Notifications] Schedule error: \(error)")
                    }
                }
            }
        }
    }

    // MARK: - Cancel

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - Helpers

    private func reminderLabel(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        }
    }

    private func shouldNotify(session: Session, settings: SettingsManager) -> Bool {
        switch session.name {
        case "PRACTICE 1", "PRACTICE 2", "PRACTICE 3":
            return settings.notifyPractice
        case "QUALIFYING":
            return settings.notifyQualifying
        case "SPRINT QUALI", "SPRINT":
            return settings.notifySprint
        case "GRAND PRIX":
            return settings.notifyRace
        default:
            return false
        }
    }
}
