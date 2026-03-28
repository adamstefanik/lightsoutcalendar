import SwiftUI

private struct CompoundBadge: View {
    let compound: String

    private var label: String {
        switch compound {
        case "SOFT": return "S"
        case "MEDIUM": return "M"
        case "HARD": return "H"
        case "INTERMEDIATE": return "I"
        case "WET": return "W"
        default: return ""
        }
    }

    private var color: Color {
        switch compound {
        case "SOFT": return .red
        case "MEDIUM": return .yellow
        case "HARD": return .white
        case "INTERMEDIATE": return .green
        case "WET": return .blue
        default: return .clear
        }
    }

    var body: some View {
        if !label.isEmpty {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)
                .frame(width: 16, alignment: .center)
        }
    }
}

private struct TeamBadge: View {
    let team: String
    var trailingPadding: CGFloat = 6

    private var style: TeamStyle { TeamStyle.from(team: team) }

    var body: some View {
        Text(style.abbreviation)
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(style.color)
            .lineLimit(1)
            .frame(width: 22, alignment: .leading)
            .padding(.trailing, trailingPadding)
    }
}

enum SessionDisplayType {
    case race       // GP: podium P1-P3, points, fastest lap icon
    case sprint     // Sprint: podium P1-P3, sprint points, fastest lap icon
    case timing     // Qualifying, Sprint Quali: flat list, own times, segment labels, no points
    case practice   // Practice 1/2/3: flat list, deltas, laps column
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

    private var columnHeader: some View {
        Group {
            if displayType == .timing {
                HStack(spacing: 0) {
                    Text("POS.")
                        .frame(width: 37, alignment: .center)
                    Text("DRIVER")
                        .frame(width: 90, alignment: .leading).padding(.leading, 25)
                    Text("TIRE")
                        .frame(width: 27, alignment: .center)
                    Spacer()
                    HStack(spacing: 0) {
                        Text("Q")
                            .frame(width: 60, alignment: .center)
                        Text("TIME")
                            .frame(width: 50, alignment: .center)
                        Text("GAP")
                            .frame(width: 62, alignment: .trailing)
                    }
                }
            } else if displayType == .practice {
                HStack(spacing: 8) {
                    Text("POS.")
                        .frame(width: 36, alignment: .center).padding(.leading, 3)
                    Text("DRIVER").padding(.leading, 20)
                    Spacer()
                    Text("LAPS")
                        .frame(width: 50, alignment: .center)
                    Text("TIME")
                        .frame(width: 55, alignment: .trailing).padding(.trailing, 5)
                    Text("GAP")
                        .frame(width: 62, alignment: .trailing)
                }
            } else {
                HStack(spacing: 8) {
                    Text("POS.")
                        .frame(width: 36, alignment: .center).padding(.leading, 3)
                    Text("DRIVER").padding(.leading, 20)
                    Spacer()
                    Text("TIME/GAP")
                        .frame(width: 90, alignment: .trailing)
                }
            }
        }
        .font(.system(size: 10, weight: .medium))
        .foregroundColor(.f1SecondaryText)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                columnHeader

                Rectangle()
                    .fill(Color.f1Divider)
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

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
                        Group {
                            if driver.position == 11 || driver.position == 16 {
                                Rectangle()
                                    .fill(Color.f1Divider)
                                    .frame(height: 1)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                            }
                            if driver.position <= 3 {
                                PodiumRow(driver: driver, showPoints: false, showFastestLap: false, highlightFastestTime: true)
                            } else {
                                TimingRow(driver: driver)
                            }
                        }
                    case .practice:
                        PracticeRow(driver: driver)
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
        HStack(spacing: 0) {
            Text("\(driver.position)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 36, alignment: .center)

            TeamBadge(team: driver.team, trailingPadding: 6)

            Text(driver.shortName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 90, alignment: .leading)
                .lineLimit(1)

            CompoundBadge(compound: driver.compound)
                .frame(width: 20, alignment: .leading)
                .padding(.leading, 4)

            Spacer()

            HStack(spacing: 0) {
                let showSegment = !driver.segment.isEmpty && driver.segment != "Q3" && driver.segment != "SQ3"
                Text(showSegment ? "\(driver.segment):" : "")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.f1SecondaryText)
                    .frame(width: 30, alignment: .trailing)
                Text(driver.time)
                    .font(.system(size: 12, weight: driver.position == 1 ? .semibold : .regular))
                    .foregroundColor(driver.position == 1 ? .purple : .white)
                    .frame(width: 70, alignment: .trailing)
                Text(driver.gap)
                    .font(.system(size: 11))
                    .foregroundColor(.f1SecondaryText)
                    .frame(width: 62, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}

// MARK: - Practice Row

private struct PracticeRow: View {
    let driver: DriverResult

    var body: some View {
        HStack(spacing: 0) {
            Text("\(driver.position)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(driver.position == 1 ? .f1Gold : driver.position == 2 ? .f1Silver : driver.position == 3 ? .f1Bronze : .white)
                .frame(width: 36, alignment: .center)

            HStack(spacing: 2) {
                TeamBadge(team: driver.team)
                Text(driver.shortName)
                    .font(.system(size: 13, weight: driver.position == 1 ? .semibold : .medium))
                    .foregroundColor(.white)
            }

            Spacer()

            Text(driver.laps > 0 ? "\(driver.laps)" : "–")
                .font(.system(size: 12))
                .foregroundColor(.f1SecondaryText)
                .frame(width: 40, alignment: .center)

            Text(driver.time)
                .font(.system(size: 12, weight: driver.position == 1 ? .semibold : .regular))
                .foregroundColor(driver.position == 1 ? .purple : .white)
                .frame(width: 80, alignment: .trailing)

            Text(driver.gap)
                .font(.system(size: 11))
                .foregroundColor(.f1SecondaryText)
                .frame(width: 62, alignment: .trailing)
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
        Group {
            if highlightFastestTime {
                // Timing mode (qualifying P1-P3) — fixed columns matching TimingRow
                HStack(spacing: 0) {
                    Text("\(driver.position)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(positionColor)
                        .frame(width: 36, alignment: .center)

                    TeamBadge(team: driver.team, trailingPadding: 6)

                    Text(driver.shortName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.f1Text)
                        .frame(width: 90, alignment: .leading)
                        .lineLimit(1)

                    CompoundBadge(compound: driver.compound)
                        .frame(width: 20, alignment: .leading)
                        .padding(.leading, 4)

                    Spacer()

                    HStack(spacing: 0) {
                        let showSegment = !driver.segment.isEmpty && driver.segment != "Q3" && driver.segment != "SQ3"
                        Text(showSegment ? "\(driver.segment):" : "")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.f1SecondaryText)
                            .frame(width: 30, alignment: .trailing)
                        Text(driver.time)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(driver.position == 1 ? .purple : .f1Text)
                            .frame(width: 70, alignment: .trailing)
                        Text(driver.gap)
                            .font(.system(size: 11))
                            .foregroundColor(.f1SecondaryText)
                            .frame(width: 62, alignment: .trailing)
                    }
                }
            } else {
                // Race/Sprint mode
                HStack(spacing: 0) {
                    Text("\(driver.position)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(positionColor)
                        .frame(width: 36, alignment: .center)

                    HStack(spacing: 2) {
                        TeamBadge(team: driver.team)
                        Text(driver.shortName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.f1Text)
                            .lineLimit(1)
                    }

                    if showPoints && driver.points > 0 {
                        Text("+\(driver.points) pts")
                            .font(.system(size: 10))
                            .foregroundColor(.f1SecondaryText)
                            .fixedSize()
                            .padding(.leading, 6)
                    }

                    if showFastestLap && driver.fastestLap {
                        Image(systemName: "stopwatch.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.purple)
                            .padding(.leading, 6)
                        if !driver.fastestLapTime.isEmpty {
                            Text(driver.fastestLapTime)
                                .font(.system(size: 10))
                                .foregroundColor(.purple)
                                .fixedSize()
                                .padding(.leading, 4)
                        }
                    }

                    Spacer()

                    Text(driver.time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.f1Text)
                        .frame(width: 90, alignment: .trailing)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}

// MARK: - P4-P10 Row (Race/Sprint)

private struct PointsRow: View {
    let driver: DriverResult
    var showPoints: Bool = true
    var showFastestLap: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            Text("\(driver.position)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.f1Text)
                .frame(width: 36, alignment: .center)

            HStack(spacing: 2) {
                TeamBadge(team: driver.team)
                Text(driver.shortName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.f1Text)
                    .lineLimit(1)
                if showPoints && driver.points > 0 {
                    Text("+\(driver.points)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.f1SecondaryText)
                }
                if showFastestLap && driver.fastestLap {
                    Image(systemName: "stopwatch.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.purple)
                    if !driver.fastestLapTime.isEmpty {
                        Text(driver.fastestLapTime)
                            .font(.system(size: 10))
                            .foregroundColor(.purple)
                            .padding(.leading, 4)
                    }
                }
            }

            Spacer()

            Text(driver.time)
                .font(.system(size: 12))
                .foregroundColor(.f1Text)
                .frame(width: 90, alignment: .trailing)
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
        HStack(spacing: 0) {
            Text("\(driver.position)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.f1Text)
                .frame(width: 36, alignment: .center)

            HStack(spacing: 2) {
                TeamBadge(team: driver.team)
                HStack(spacing: 8) {
                    Text(driver.shortName)
                        .font(.system(size: 13))
                        .foregroundColor(.f1Text)
                    if showFastestLap && driver.fastestLap {
                        Image(systemName: "stopwatch.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.purple)
                        Text(driver.fastestLapTime)
                            .font(.system(size: 10))
                            .foregroundColor(.purple)
                            .padding(.leading, 4)
                    }
                }
            }

            Spacer()

            Text(driver.time)
                .font(.system(size: 12))
                .foregroundColor(.f1Text)
                .frame(width: 90, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
    }
}

// MARK: - DNF Row

private struct DNFRow: View {
    let driver: DriverResult

    var body: some View {
        HStack(spacing: 0) {
            Text("–")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.f1Red)
                .frame(width: 36, alignment: .center)

            HStack(spacing: 2) {
                TeamBadge(team: driver.team)
                Text(driver.shortName)
                    .font(.system(size: 13))
                    .foregroundColor(.f1Red)
            }

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

#Preview("Grand Prix") {
    NavigationStack {
        SessionResultsView(title: "GRAND PRIX", results: DriverResult.previewResults)
    }
    .preferredColorScheme(.dark)
}

#Preview("Qualifying") {
    NavigationStack {
        SessionResultsView(title: "QUALIFYING", results: DriverResult.previewResults, displayType: .timing)
    }
    .preferredColorScheme(.dark)
}

#Preview("Practice") {
    NavigationStack {
        SessionResultsView(title: "PRACTICE 1", results: DriverResult.previewResults, displayType: .practice)
    }
    .preferredColorScheme(.dark)
}
