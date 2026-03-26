import SwiftUI

enum SessionDisplayType {
    case race       // GP: podium P1-P3, points, fastest lap icon
    case sprint     // Sprint: podium P1-P3, sprint points, fastest lap icon
    case timing     // Practice, Qualifying, Sprint Quali: flat list, times + deltas, no points, no fastest lap icon
}

struct SessionResultsView: View {
    let title: String
    let results: [DriverResult]
    var displayType: SessionDisplayType = .race

    private var finishers: [DriverResult] {
        results.filter { !$0.dnf }.sorted { $0.position < $1.position }
    }

    private var dnfs: [DriverResult] {
        results.filter { $0.dnf }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(finishers) { driver in
                    switch displayType {
                    case .race, .sprint:
                        if driver.position <= 3 {
                            PodiumRow(driver: driver, showPoints: true, showFastestLap: true)
                        } else if driver.position <= 10 {
                            PointsRow(driver: driver, showPoints: true, showFastestLap: true)
                        } else {
                            CompactRow(driver: driver, showFastestLap: true)
                        }
                    case .timing:
                        if driver.position <= 3 {
                            PodiumRow(driver: driver, showPoints: false, showFastestLap: false, highlightFastestTime: true)
                        } else {
                            TimingRow(driver: driver)
                        }
                    }
                }

                if !dnfs.isEmpty {
                    Rectangle()
                        .fill(Color.f1Divider)
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                    ForEach(dnfs) { driver in
                        DNFRow(driver: driver)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color("f1Background"))
        .navigationTitle(title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
    }
}

// MARK: - Timing Row (Practice, Qualifying, Sprint Quali)

private struct TimingRow: View {
    let driver: DriverResult

    var body: some View {
        HStack(spacing: 12) {
            Text("\(driver.position)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 36, alignment: .center)

            Text(driver.driverName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            Text(driver.time)
                .font(.system(size: 11, weight: driver.position == 1 ? .semibold : .regular))
                .foregroundColor(driver.position == 1 ? .purple : .white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}

// MARK: - P1-P3 Row (Race/Sprint)

private struct PodiumRow: View {
    let driver: DriverResult
    var showPoints: Bool = true
    var showFastestLap: Bool = true
    var highlightFastestTime: Bool = false

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
            Text("\(driver.position)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(positionColor)
                .frame(width: 36, alignment: .center)

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

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(driver.time)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(highlightFastestTime && driver.position == 1 ? .purple : .f1Text)
                if showPoints && driver.points > 0 {
                    Text("+\(driver.points) pts")
                        .font(.system(size: 10))
                        .foregroundColor(.f1SecondaryText)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - P4-P10 Row (Race/Sprint)

private struct PointsRow: View {
    let driver: DriverResult
    var showPoints: Bool = true
    var showFastestLap: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Text("\(driver.position)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.f1Text)
                .frame(width: 36, alignment: .center)

            HStack(spacing: 8) {
                Text(driver.driverName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.f1Text)
                if showFastestLap && driver.fastestLap {
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.purple)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Text(driver.time)
                    .font(.system(size: 11))
                    .foregroundColor(.f1Text)
                if showPoints && driver.points > 0 {
                    Text("+\(driver.points)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.f1SecondaryText)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}

// MARK: - P11+ Row (Race/Sprint)

private struct CompactRow: View {
    let driver: DriverResult
    var showFastestLap: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Text("\(driver.position)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.f1Text)
                .frame(width: 36, alignment: .center)

            HStack(spacing: 8) {
                Text(driver.driverName)
                    .font(.system(size: 13))
                    .foregroundColor(.f1Text)
                if showFastestLap && driver.fastestLap {
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.purple)
                }
            }

            Spacer()

            Text(driver.time)
                .font(.system(size: 11))
                .foregroundColor(.f1Text)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}

// MARK: - DNF Row

private struct DNFRow: View {
    let driver: DriverResult

    var body: some View {
        HStack(spacing: 12) {
            Text("–")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.f1Red)
                .frame(width: 36, alignment: .center)

            Text(driver.driverName)
                .font(.system(size: 13))
                .foregroundColor(.f1Red)

            Spacer()

            Text("DNF")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.f1Red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SessionResultsView(title: "Grand Prix Results", results: DriverResult.previewResults)
    }
    .preferredColorScheme(.dark)
}
