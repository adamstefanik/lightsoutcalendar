import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Notifications
                Section {
                    Toggle("Practice Sessions", isOn: $settings.notifyPractice)
                    Toggle("Qualifying", isOn: $settings.notifyQualifying)
                    Toggle("Sprint", isOn: $settings.notifySprint)
                    Toggle("Grand Prix", isOn: $settings.notifyRace)
                } header: {
                    Text("NOTIFICATIONS")
                }

                // MARK: - Remind Me Before
                Section {
                    Picker("Remind me before", selection: $settings.reminderMinutes) {
                        ForEach(SettingsManager.reminderOptions, id: \.self) { minutes in
                            Text(reminderLabel(minutes)).tag(minutes)
                        }
                    }
                } header: {
                    Text("REMIND ME BEFORE")
                }

                // MARK: - Weather
                Section {
                    Picker("Temperature", selection: $settings.temperatureUnit) {
                        ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                } header: {
                    Text("WEATHER")
                }

                // MARK: - About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.f1SecondaryText)
                    }
                    HStack {
                        Text("Data")
                        Spacer()
                        Text("OpenF1 API")
                            .foregroundColor(.f1SecondaryText)
                    }
                    HStack {
                        Text("Weather")
                        Spacer()
                        Text("OpenWeatherMap")
                            .foregroundColor(.f1SecondaryText)
                    }
                } header: {
                    Text("ABOUT")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("f1Background"))
            .navigationTitle("Settings")
            .tint(Color.f1Red)
            .onChange(of: settings.notifyPractice) { rescheduleNotifications() }
            .onChange(of: settings.notifyQualifying) { rescheduleNotifications() }
            .onChange(of: settings.notifySprint) { rescheduleNotifications() }
            .onChange(of: settings.notifyRace) { rescheduleNotifications() }
            .onChange(of: settings.reminderMinutes) { rescheduleNotifications() }
            .task {
                await NotificationManager.shared.requestPermission()
            }
        }
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

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func rescheduleNotifications() {
        NotificationManager.shared.scheduleNotifications(
            for: F1Calendar.races,
            settings: settings
        )
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
