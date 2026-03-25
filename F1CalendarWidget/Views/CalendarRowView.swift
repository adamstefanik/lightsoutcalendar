import SwiftUI

struct CalendarRowView: View {
    let race: Race
    let isNextRace: Bool

    private var isCompleted: Bool { race.isCompleted }

    var body: some View {
        HStack(spacing: 12) {
            // Red left border for next race
            if isNextRace {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.f1Red)
                    .frame(width: 3)
            }

            // Country flag
            Text(race.countryFlag)
                .font(.system(size: 32))

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

                    if isCompleted {
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
                    Text("\(race.daysUntilRace)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.f1Red)
                    Text("DAYS")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.f1Red)
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
