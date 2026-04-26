import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    @ObservedObject var raceStore: RaceStore

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
                    Picker("First reminder", selection: $settings.reminderMinutes) {
                        ForEach(SettingsManager.reminderOptions, id: \.self) { minutes in
                            Text(reminderLabel(minutes)).tag(minutes)
                        }
                    }
                    Picker("Second reminder", selection: $settings.secondReminderMinutes) {
                        ForEach(SettingsManager.secondReminderOptions, id: \.self) { minutes in
                            Text(secondReminderLabel(minutes)).tag(minutes)
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
                        Text("Race data")
                        Spacer()
                        Text("OpenF1 API")
                            .foregroundColor(.f1SecondaryText)
                    }
                    HStack {
                        Text("Weather")
                        Spacer()
                        Text("OpenWeather API")
                            .foregroundColor(.f1SecondaryText)
                    }
                    HStack {
                        Text("Circuits")
                        Spacer()
                        Text("Jules Roy, CC BY 4.0, modified")
                            .foregroundColor(.f1SecondaryText)
                    }
                    HStack {
                        Text("Weather Icons")
                        Spacer()
                        Text("Bas Milius, MIT")
                            .foregroundColor(.f1SecondaryText)
                    }
                } header: {
                    Text("ABOUT")
                }

                // MARK: - Disclaimer
                
                footer: {
                    Text("This app is an independent project and is not affiliated with, endorsed by, sponsored by, or associated with Formula 1, FIA, Formula One Licensing BV, any Formula 1 team, driver, circuit owner, or broadcaster. All trademarks are property of their respective owners. Data is sourced from public third-party APIs.")
                        .font(.caption2)
                        .foregroundColor(.f1SecondaryText)
                        .padding(.top, 8)
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
            .onChange(of: settings.secondReminderMinutes) { rescheduleNotifications() }
            .task {
                _ = await NotificationManager.shared.requestPermission()
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

    private func secondReminderLabel(_ minutes: Int) -> String {
        if minutes == 0 { return "Off" }
        if minutes == 1440 { return "1 day" }
        return reminderLabel(minutes)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func rescheduleNotifications() {
        NotificationManager.shared.scheduleNotifications(
            for: raceStore.races,
            settings: settings
        )
    }
}

// MARK: - Preview

#Preview {
    SettingsView(raceStore: RaceStore())
        .preferredColorScheme(.dark)
}
