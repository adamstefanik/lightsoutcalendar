import SwiftUI

struct RaceHeaderView: View {
    let race: Race

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Track box
            DynamicTrackView(raceShortName: race.shortName)
                .frame(width: 95, height: 95)
                .padding(2)

            // Race info
            VStack(alignment: .leading, spacing: 6) {
                Text(race.city)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.f1Text)
                    .padding(.top, 14)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text("\(race.name.uppercased()) 2026")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.f1SecondaryText)
                    .lineLimit(2)

                Text("\(race.weekendDayRange) \(race.monthLabel)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.f1SecondaryText)
                    .lineLimit(1)

            }
            .padding(.leading, 4)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Countdown + session badge
            VStack(alignment: .trailing, spacing: 6) {
                // Session badge
                Text(badgeLabel)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(RoundedRectangle(cornerRadius: 3).fill(race.isCanceled ? Color.f1SecondaryText : Color.f1Red))
                    .padding(.top, 35)

                // Countdown
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    HStack(alignment: .bottom, spacing: 6) {
                        CountdownBlock(value: race.isCanceled ? "00" : countdownDays(now: context.date), label: "DAYS")
                        CountdownBlock(value: race.isCanceled ? "00" : countdownHours(now: context.date), label: "HRS")
                        CountdownBlock(value: race.isCanceled ? "00" : countdownMins(now: context.date), label: "MINS")
                    }
                }
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.top, 75)
    }

    private var badgeLabel: String {
        if race.isCanceled { return "CANCELED" }
        if race.isCompleted { return "FINISHED" }
        return race.currentSessionBadge
    }

    // MARK: - Countdown

    private func secondsUntilNext(now: Date) -> Int {
        let target = race.nextSessionDate ?? race.raceDate
        return max(0, Int(target.timeIntervalSince(now)))
    }

    private func countdownDays(now: Date) -> String {
        String(format: "%02d", secondsUntilNext(now: now) / 86400)
    }

    private func countdownHours(now: Date) -> String {
        String(format: "%02d", (secondsUntilNext(now: now) % 86400) / 3600)
    }

    private func countdownMins(now: Date) -> String {
        String(format: "%02d", (secondsUntilNext(now: now) % 3600) / 60)
    }
}

// MARK: - Countdown Block

private struct CountdownBlock: View {
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
