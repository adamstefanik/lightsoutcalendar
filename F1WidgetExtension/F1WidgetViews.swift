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
        default:             F1LargeView(race: entry.nextRace)
        }
    }
}

// MARK: - Large Widget

struct F1LargeView: View {
    let race: Race
    @Environment(\.widgetRenderingMode) var renderingMode

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            // HEADER
            HStack(alignment: .center, spacing: 12) {
                
                // Track box
                DynamicTrackView(raceShortName: race.shortName)
                    .frame(width: 75, height: 75)
                    .padding(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.f1Border, lineWidth: 1)
                    )
                
                // Race info
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6){
                        Text(race.city)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.f1Text)
                    }
                    Text("FORMULA 1 \(race.name.uppercased()) 2026")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.f1SecondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("\(race.weekendDayRange) \(race.monthLabel)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.f1SecondaryText)
                        .lineLimit(1)
                }
                .padding(.leading, 7)

                Spacer()

                // Session badge + countdown
                VStack(alignment: .trailing, spacing: 6) {
                    Text(race.currentSessionBadge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(renderingMode == .fullColor ? .white : .primary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background {
                            if renderingMode == .fullColor {
                                RoundedRectangle(cornerRadius: 3).fill(Color.f1Red)
                            } else {
                                RoundedRectangle(cornerRadius: 3).stroke(Color.primary, lineWidth: 1)
                            }
                        }
                        .padding(.top,29)

                    HStack(alignment: .bottom, spacing: 6) {
                        CountdownUnit(value: countdownDays,  label: "DAYS")
                        CountdownUnit(value: countdownHours, label: "HRS")
                        CountdownUnit(value: countdownMins,  label: "MINS")
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 20)

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
            .padding(.top, 10)

            Spacer(minLength: 0)

            Text("github.com/adamstefanik")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(.f1SecondaryText.opacity(0.5))
                .offset(y: +10)
        }
    }

    private var secondsUntilNext: Int {
        let target = race.nextSessionDate ?? race.raceDate
        return max(0, Int(target.timeIntervalSinceNow))
    }
    private var countdownDays: String {
        String(format: "%02d", secondsUntilNext / 86400)
    }
    private var countdownHours: String {
        String(format: "%02d", (secondsUntilNext % 86400) / 3600)
    }
    private var countdownMins: String {
        String(format: "%02d", (secondsUntilNext % 3600) / 60)
    }
}

// MARK: - Medium Widget

struct F1MediumView: View {
    let race: Race
    @Environment(\.widgetRenderingMode) var renderingMode

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                
                // Track box
                DynamicTrackView(raceShortName: race.shortName)
                    .frame(width: 60, height: 60)
                    .padding(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.f1Border, lineWidth: 1)
                    )
                    .padding(.top, 7)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text(race.city)
                            .font(.system(size: 13, weight: .bold)).foregroundColor(.f1Text)
                    }
                    Text("FORMULA 1 \(race.name.uppercased()) 2026")
                        .font(.system(size: 7)).foregroundColor(.f1SecondaryText).lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("\(race.weekendDayRange) \(race.monthLabel)")
                        .font(.system(size: 8, weight: .regular))
                        .foregroundColor(.f1SecondaryText)
                        .lineLimit(1)
                }
                .padding(.leading, 7)
                .padding(.top, 5)
                
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(race.currentSessionBadge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(renderingMode == .fullColor ? .white : .primary)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background {
                            if renderingMode == .fullColor {
                                RoundedRectangle(cornerRadius: 3).fill(Color.f1Red)
                            } else {
                                RoundedRectangle(cornerRadius: 3).stroke(Color.primary, lineWidth: 1)
                            }
                        }
                        .padding(.top,24)

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

            Text("github.com/adamstefanik")
                .font(.system(size: 7, weight: .medium, design: .monospaced))
                .foregroundColor(.f1SecondaryText.opacity(0.5))
                .offset(y: -6)
        }
    }

    private var secondsUntilNext: Int {
        let target = race.nextSessionDate ?? race.raceDate
        return max(0, Int(target.timeIntervalSinceNow))
    }
    private var mediumCountdownDays: String {
        String(format: "%02d", secondsUntilNext / 86400)
    }
    private var mediumCountdownHours: String {
        String(format: "%02d", (secondsUntilNext % 86400) / 3600)
    }
    private var mediumCountdownMins: String {
        String(format: "%02d", (secondsUntilNext % 3600) / 60)
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

                if session.isLive {
                    Text("LIVE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 3).fill(Color.f1Red))
                        .frame(width: 100, alignment: .trailing)
                } else {
                    Text(session.time)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.f1Text)
                        .frame(width: 100, alignment: .trailing)
                        .lineLimit(1)
                }
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
// MARK: - Dynamic Track View

struct DynamicTrackView: View {
    let raceShortName: String

    var body: some View {
        Image("track\(raceShortName)")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundColor(.f1Red)
    }
}
// MARK: - Previews

#Preview("Large", as: .systemLarge) {
    F1CalendarWidget()
} timeline: {
    F1WidgetEntry(date: .now, nextRace: F1Calendar.nextRace ?? F1Calendar.fallbackRaces[2])
}

#Preview("Large – Live FP1", as: .systemLarge) {
    F1CalendarWidget()
} timeline: {
    F1WidgetEntry(date: .now, nextRace: .previewLive)
}

#Preview("Medium", as: .systemMedium) {
    F1CalendarWidget()
} timeline: {
    F1WidgetEntry(date: .now, nextRace: F1Calendar.nextRace ?? F1Calendar.fallbackRaces[2])
}

#Preview("Medium – Live FP1", as: .systemMedium) {
    F1CalendarWidget()
} timeline: {
    F1WidgetEntry(date: .now, nextRace: .previewLive)
}
