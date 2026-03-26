import SwiftUI

struct RaceResultsView: View {
    let results: [DriverResult]
    var displayType: SessionDisplayType = .race

    private var showPoints: Bool {
        displayType == .race || displayType == .sprint
    }

    private var showFastestLap: Bool {
        displayType == .race || displayType == .sprint
    }

    private var podium: [DriverResult] {
        results.filter { !$0.dnf && $0.position <= 3 }.sorted { $0.position < $1.position }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("RESULTS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.f1SecondaryText)

            // Podium cards
            ForEach(podium) { driver in
                PodiumCard(driver: driver, showPoints: showPoints, showFastestLap: showFastestLap)
            }

            // Full results link
            NavigationLink {
                SessionResultsView(title: "Results", results: results, displayType: displayType)
            } label: {
                Text("Tap for full results")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.f1SecondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 34)
        .padding(.top, 16)
        .padding(.bottom, 0)
    }
}

// MARK: - Podium Card

private struct PodiumCard: View {
    let driver: DriverResult
    var showPoints: Bool = true
    var showFastestLap: Bool = true

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
                HStack(spacing: 8) {
                    Text(driver.driverName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.f1Text)
                    if showFastestLap && driver.fastestLap {
                        Image(systemName: "stopwatch.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.purple)
                    }
                }
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
                .fill(Color("f1Surface"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(positionColor.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScrollView {
            RaceResultsView(results: DriverResult.previewResults)
        }
        .background(Color("f1Background"))
    }
    .preferredColorScheme(.dark)
}
