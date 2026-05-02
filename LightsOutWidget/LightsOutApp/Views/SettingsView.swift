import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    @ObservedObject var raceStore: RaceStore

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
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

                // MARK: - Spoiler Protection
                Section {
                    Toggle("Hide Results", isOn: $settings.hideSpoilers)
                } header: {
                    Text("SPOILER PROTECTION")
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
                } footer: {
                    Text("This app is an independent project and is not affiliated with, endorsed by, sponsored by, or associated with Formula 1, FIA, Formula One Licensing BV, any Formula 1 team, driver, circuit owner, or broadcaster. All trademarks are property of their respective owners. Data is sourced from public third-party APIs.")
                        .font(.caption2)
                        .foregroundColor(.f1SecondaryText)
                        .padding(.top, 8)
                }
            }
            .contentMargins(.top, 60, for: .scrollContent)
            .scrollContentBackground(.hidden)
            .background(Color("f1Background"))
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

            // Custom Top Bar with Gradient Fade
            HStack {
                Spacer()
                Text("SETTINGS")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background {
                VStack(spacing: 0) {
                    Color("f1Background")
                        .ignoresSafeArea(edges: .top)
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("f1Background"),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 40)
                }
            }
            }
            .toolbar(.hidden, for: .navigationBar)
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
