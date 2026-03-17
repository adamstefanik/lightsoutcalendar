import SwiftUI
import WidgetKit

// MARK: - Entry View Router

struct F1WidgetEntryView: View {
    var entry: F1WidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemLarge:   F1LargeView(race: entry.nextRace)
        case .systemMedium:  F1MediumView(race: entry.nextRace)
        case .systemSmall:   F1SmallView(race: entry.nextRace)
        default:             F1LargeView(race: entry.nextRace)
        }
    }
}

// MARK: - Large Widget

struct F1LargeView: View {
    let race: Race

    var body: some View {
        VStack(spacing: 0) {
            // HEADER
            HStack(alignment: .center, spacing: 12) {
                // Date box with border
                VStack(spacing: 0) {
                    Text(race.weekendDayRange)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.f1Text)
                    Text(race.monthLabel)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.f1Text)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.f1Border, lineWidth: 1)
                )

                // Race info
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(race.countryFlag)
                            .font(.system(size: 15))
                        Text(race.city)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.f1Text)
                    }
                    Text("FORMULA 1 \(race.name.uppercased()) 2026")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.f1SecondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Session badge + countdown
                VStack(alignment: .trailing, spacing: 6) {
                    Text(race.currentSessionBadge)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.f1Red)
                        )

                    HStack(alignment: .bottom, spacing: 6) {
                        CountdownUnit(value: countdownDays,  label: "DAYS")
                        CountdownUnit(value: countdownHours, label: "HRS")
                        CountdownUnit(value: countdownMins,  label: "MINS")
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            // DIVIDER
            Rectangle()
                .fill(Color.f1Divider)
                .frame(height: 1)

            // SESSION ROWS
            VStack(spacing: 0) {
                ForEach(Array(race.sessions.enumerated()), id: \.offset) { _, session in
                    SessionRowView(session: session)
                }
            }

            Spacer(minLength: 0)

            Text("github.com/adamstefanik")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(.f1SecondaryText.opacity(0.5))
                .padding(.bottom, 6)
        }
    }

    private var secondsUntilRace: Int {
        max(0, Int(race.raceDate.timeIntervalSinceNow))
    }
    private var countdownDays: String {
        String(format: "%02d", secondsUntilRace / 86400)
    }
    private var countdownHours: String {
        String(format: "%02d", (secondsUntilRace % 86400) / 3600)
    }
    private var countdownMins: String {
        String(format: "%02d", (secondsUntilRace % 3600) / 60)
    }
}

// MARK: - Medium Widget

struct F1MediumView: View {
    let race: Race

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                VStack(spacing: 0) {
                    Text(race.weekendDayRange)
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.f1Text)
                    Text(race.monthLabel)
                        .font(.system(size: 11, weight: .bold)).foregroundColor(.f1Text)
                }
                .padding(7)
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.f1Border, lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(race.countryFlag)
                            .font(.system(size: 13))
                        Text(race.city)
                            .font(.system(size: 13, weight: .bold)).foregroundColor(.f1Text)
                    }
                    Text("FORMULA 1 \(race.name.uppercased()) 2026")
                        .font(.system(size: 7)).foregroundColor(.f1SecondaryText).lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(race.currentSessionBadge)
                        .font(.system(size: 9, weight: .black)).foregroundColor(.white)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(RoundedRectangle(cornerRadius: 3).fill(Color.f1Red))

                    HStack(alignment: .bottom, spacing: 5) {
                        CountdownUnit(value: mediumCountdownDays, label: "DAYS")
                        CountdownUnit(value: mediumCountdownHours, label: "HRS")
                        CountdownUnit(value: mediumCountdownMins, label: "MINS")
                    }
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)

            Rectangle().fill(Color.f1Divider).frame(height: 1)

            ForEach(Array(race.sessions.suffix(2).enumerated()), id: \.offset) { _, session in
                SessionRowView(session: session)
            }

            Spacer(minLength: 0)

            Text("github.com/adamstefanik")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(.f1SecondaryText.opacity(0.5))
                .padding(.bottom, 4)
        }
    }

    private var secondsUntilRace: Int {
        max(0, Int(race.raceDate.timeIntervalSinceNow))
    }
    private var mediumCountdownDays: String {
        String(format: "%02d", secondsUntilRace / 86400)
    }
    private var mediumCountdownHours: String {
        String(format: "%02d", (secondsUntilRace % 86400) / 3600)
    }
    private var mediumCountdownMins: String {
        String(format: "%02d", (secondsUntilRace % 3600) / 60)
    }
}

// MARK: - Small Widget

struct F1SmallView: View {
    let race: Race

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Spacer()
                    Text(race.currentSessionBadge)
                        .font(.system(size: 9, weight: .black)).foregroundColor(.white)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(RoundedRectangle(cornerRadius: 3).fill(Color.f1Red))
                }
                Spacer()
                Text(race.roundLabel)
                    .font(.system(size: 10, weight: .black)).foregroundColor(.f1Red)
                HStack(spacing: 4) {
                    Text(race.countryFlag).font(.system(size: 14))
                    Text(race.city).font(.system(size: 14, weight: .bold)).foregroundColor(.f1Text)
                }
                HStack(spacing: 4) {
                    Text(race.weekendDayRange)
                        .font(.system(size: 11, weight: .semibold)).foregroundColor(.f1Text)
                    Text(race.monthLabel)
                        .font(.system(size: 11)).foregroundColor(.f1SecondaryText)
                }
            }
            .padding(12)
        }
    }
}

// MARK: - Session Row

struct SessionRowView: View {
    let session: Session

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(session.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.f1Text)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(session.day)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.f1SecondaryText)
                    .frame(width: 72, alignment: .leading)

                Text(session.time)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.f1Text)
                    .frame(width: 100, alignment: .leading)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Countdown Unit

struct CountdownUnit: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.f1Text)
            Text(label)
                .font(.system(size: 6, weight: .medium))
                .foregroundColor(.f1SecondaryText)
        }
    }
}

// MARK: - Previews

#Preview("Large", as: .systemLarge) {
    F1CalendarWidget()
} timeline: {
    F1WidgetEntry(date: .now, nextRace: F1Calendar.fallbackRaces.first!)
}

#Preview("Medium", as: .systemMedium) {
    F1CalendarWidget()
} timeline: {
    F1WidgetEntry(date: .now, nextRace: F1Calendar.fallbackRaces.first!)
}

#Preview("Small", as: .systemSmall) {
    F1CalendarWidget()
} timeline: {
    F1WidgetEntry(date: .now, nextRace: F1Calendar.fallbackRaces.first!)
}
