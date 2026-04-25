import Foundation

struct DriverResult: Codable, Identifiable {
    var id: String { "\(position)_\(driverName)" }

    var shortName: String {
        let parts = driverName.split(separator: " ", maxSplits: 1)
        guard parts.count == 2, let first = parts.first else { return driverName }
        return "\(first.prefix(1)). \(parts[1])"
    }
    let position: Int
    let driverName: String
    let team: String
    let time: String
    let gap: String       // gap from P1 (e.g. "+0.333s"), empty for P1 or non-timing sessions
    let points: Int
    let fastestLap: Bool
    let fastestLapTime: String
    let segment: String
    let dnf: Bool
    let laps: Int
    let compound: String  // "SOFT", "MEDIUM", "HARD", "INTERMEDIATE", "WET", or ""
}

#if DEBUG
extension DriverResult {
    static let previewResults: [DriverResult] = [
        DriverResult(position: 1,  driverName: "Driver One",        team: "Team A", time: "1:23.456",    gap: "",           points: 25, fastestLap: false, fastestLapTime: "", segment: "Q3", dnf: false, laps: 57, compound: "SOFT"),
        DriverResult(position: 2,  driverName: "Driver Two",        team: "Team B", time: "1:23.789",    gap: "+0.333s",    points: 18, fastestLap: true,  fastestLapTime: "1:28.456", segment: "Q3", dnf: false, laps: 57, compound: "SOFT"),
        DriverResult(position: 3,  driverName: "Driver Three",      team: "Team C", time: "1:23.901",    gap: "+0.445s",    points: 15, fastestLap: false, fastestLapTime: "", segment: "Q3", dnf: false, laps: 57, compound: "SOFT"),
        DriverResult(position: 4,  driverName: "Driver Four",       team: "Team B", time: "1:24.012",    gap: "+0.556s",    points: 12, fastestLap: false, fastestLapTime: "", segment: "Q3", dnf: false, laps: 57, compound: "SOFT"),
        DriverResult(position: 5,  driverName: "Driver Five",       team: "Team D", time: "1:24.234",    gap: "+0.778s",    points: 10, fastestLap: false, fastestLapTime: "", segment: "Q3", dnf: false, laps: 57, compound: "SOFT"),
        DriverResult(position: 6,  driverName: "Driver Six",        team: "Team C", time: "1:24.445",    gap: "+0.989s",    points: 8,  fastestLap: false, fastestLapTime: "", segment: "Q3", dnf: false, laps: 57, compound: "SOFT"),
        DriverResult(position: 7,  driverName: "Driver Seven",      team: "Team E", time: "1:24.567",    gap: "+1.111s",    points: 6,  fastestLap: false, fastestLapTime: "", segment: "Q3", dnf: false, laps: 57, compound: "SOFT"),
        DriverResult(position: 8,  driverName: "Driver Eight",      team: "Team F", time: "1:24.789",    gap: "+1.333s",    points: 4,  fastestLap: false, fastestLapTime: "", segment: "Q3", dnf: false, laps: 57, compound: "MEDIUM"),
        DriverResult(position: 9,  driverName: "Driver Nine",       team: "Team G", time: "1:24.901",    gap: "+1.445s",    points: 2,  fastestLap: false, fastestLapTime: "", segment: "Q3", dnf: false, laps: 57, compound: "SOFT"),
        DriverResult(position: 10, driverName: "Driver Ten",        team: "Team H", time: "1:25.012",    gap: "+1.556s",    points: 1,  fastestLap: false, fastestLapTime: "", segment: "Q3", dnf: false, laps: 57, compound: "SOFT"),
        DriverResult(position: 11, driverName: "Driver Eleven",     team: "Team I", time: "1:25.234",    gap: "+1.778s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q2", dnf: false, laps: 56, compound: "SOFT"),
        DriverResult(position: 12, driverName: "Driver Twelve",     team: "Team D", time: "1:25.445",    gap: "+1.989s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q2", dnf: false, laps: 56, compound: "MEDIUM"),
        DriverResult(position: 13, driverName: "Driver Thirteen",   team: "Team F", time: "1:25.567",    gap: "+2.111s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q2", dnf: false, laps: 56, compound: "SOFT"),
        DriverResult(position: 14, driverName: "Driver Fourteen",   team: "Team J", time: "1:25.789",    gap: "+2.333s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q2", dnf: false, laps: 56, compound: "MEDIUM"),
        DriverResult(position: 15, driverName: "Driver Fifteen",    team: "Team I", time: "1:25.901",    gap: "+2.445s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q2", dnf: false, laps: 56, compound: "SOFT"),
        DriverResult(position: 16, driverName: "Driver Sixteen",    team: "Team H", time: "1:26.012",    gap: "+2.556s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q1", dnf: false, laps: 55, compound: "HARD"),
        DriverResult(position: 17, driverName: "Driver Seventeen",  team: "Team J", time: "1:26.234",    gap: "+2.778s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q1", dnf: false, laps: 55, compound: "MEDIUM"),
        DriverResult(position: 18, driverName: "Driver Eighteen",   team: "Team G", time: "1:26.445",    gap: "+2.989s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q1", dnf: false, laps: 55, compound: "HARD"),
        DriverResult(position: 19, driverName: "Driver Nineteen",   team: "Team A", time: "1:26.567",    gap: "+3.111s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q1", dnf: false, laps: 0,  compound: "SOFT"),
        DriverResult(position: 20, driverName: "Driver Twenty",     team: "Team E", time: "1:26.789",    gap: "+3.333s",    points: 0,  fastestLap: false, fastestLapTime: "", segment: "Q1", dnf: false, laps: 0,  compound: "MEDIUM"),
    ]
}
#endif
