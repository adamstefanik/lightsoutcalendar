import SwiftUI

struct CalendarRowView: View {
    let race: Race
    let isNextRace: Bool

    private var isCompleted: Bool { race.isCompleted }

    private var nextSession: Session? {
        let now = Date()
        return race.sessions.first { ($0.startDate ?? .distantPast) > now }
    }

    private func countdownText(now: Date) -> String {
        guard let session = nextSession, let start = session.startDate else { return "" }
        let total = Int(start.timeIntervalSince(now))
        guard total > 0 else { return "" }
        let d = total / 86400
        let h = (total % 86400) / 3600
        let m = (total % 3600) / 60
        if d > 0 {
            return "\(d)d \(h)h \(m)m"
        } else if h > 0 {
            return "\(h)h \(m)m"
        } else {
            return "\(m)m"
        }
    }

    private var nextSessionLabel: String {
        guard let session = nextSession else { return "" }
        return "\(session.name) starts in"
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            HStack(spacing: 12) {
                // Red left border for next race
                if isNextRace {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.f1Red)
                        .frame(width: 3)
                }

                // Race info
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("\(race.roundLabel) \(race.city)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.f1Text)

                        if race.sprint {
                            Text("SPRINT")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(RoundedRectangle(cornerRadius: 3).fill(Color.f1Red))
                        }

                        if race.isCanceled {
                            Text("CANCELED")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.f1SecondaryText)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(RoundedRectangle(cornerRadius: 3).stroke(Color.f1SecondaryText, lineWidth: 1))
                        } else if isCompleted {
                            Text("COMPLETED")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.f1SecondaryText)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(RoundedRectangle(cornerRadius: 3).stroke(Color.f1SecondaryText, lineWidth: 1))
                        }
                    }

                    Text("\(race.weekendDayRange) \(race.monthLabel) · \(race.circuit)")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.f1SecondaryText)
                        .lineLimit(1)
                }

                Spacer()

                // Right side: countdown for next race, race date for others
                if isNextRace {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(countdownText(now: context.date))
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.f1Red)
                        Text(nextSessionLabel)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.f1Red)
                            .lineLimit(1)
                    }
                } else {
                    Text(raceDateFormatted)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.f1SecondaryText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .opacity(isCompleted ? 0.45 : 1.0)
        }
    }

    private var raceDateFormatted: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM"
        fmt.locale = Locale(identifier: "en_US")
        return fmt.string(from: race.raceDate)
    }
}

// MARK: - Previews

#Preview("Next Race") {
    CalendarRowView(race: F1Calendar.fallbackRaces[2], isNextRace: true)
        .background(Color("f1Background"))
        .preferredColorScheme(.dark)
}

#Preview("Sprint") {
    CalendarRowView(race: F1Calendar.fallbackRaces[1], isNextRace: false)
        .background(Color("f1Background"))
        .preferredColorScheme(.dark)
}

#Preview("Completed") {
    CalendarRowView(race: F1Calendar.fallbackRaces[0], isNextRace: false)
        .background(Color("f1Background"))
        .preferredColorScheme(.dark)
}
