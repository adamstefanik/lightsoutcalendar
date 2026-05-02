import SwiftUI

struct RaceResultsView: View {
    let results: [DriverResult]
    var displayType: SessionDisplayType = .race
    var sessionName: String = ""

    private var showPoints: Bool {
        displayType == .race || displayType == .sprint
    }

    private var showFastestLap: Bool { true }

    private var podium: [DriverResult] {
        results.filter { !$0.dnf && $0.position <= 3 }.sorted { $0.position < $1.position }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(sessionName.isEmpty ? "RESULTS" : "RESULTS FROM \(sessionName)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.f1SecondaryText)

            // Podium cards
            ForEach(podium) { driver in
                PodiumCard(driver: driver, showPoints: showPoints, showFastestLap: showFastestLap, sessionName: sessionName)
            }

            // Full results link
            NavigationLink {
                SessionResultsView(title: "Results", results: results, displayType: displayType)
            } label: {
                Text("Tap for full results")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.f1SecondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 0)
    }
}

// MARK: - Podium Card

private struct PodiumCard: View {
    let driver: DriverResult
    var showPoints: Bool = true
    var showFastestLap: Bool = true
    var sessionName: String = ""

    private var positionColor: Color {
        switch driver.position {
        case 1: return .f1Gold
        case 2: return .f1Silver
        case 3: return .f1Bronze
        default: return .f1Text
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("P\(driver.position)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(positionColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(driver.driverName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.f1Text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(driver.team)
                    .font(.system(size: 11))
                    .foregroundColor(.f1SecondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if !driver.time.isEmpty {
                    Text(driver.time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(driver.dnf ? .f1Red : .f1Text)
                }
                if showPoints {
                    Text("+\(driver.points) pts")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.f1SecondaryText)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.f1Carbon)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(positionColor.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Spoiler Cover

struct SpoilerCoverView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 18))
                .foregroundColor(.f1SecondaryText)
            Text("RESULTS HIDDEN")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.f1SecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.f1Carbon)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.f1SecondaryText.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}
