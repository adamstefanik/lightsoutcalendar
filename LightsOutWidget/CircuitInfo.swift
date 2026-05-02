import Foundation

struct CircuitInfo {
    let circuitId: String
    let length: String
    let turns: Int
    let lapRecord: String           // fastest race lap all-time
    let lapRecordHolder: String
    let lapRecordYear: Int
    var lapRecordSession: String = "Grand Prix"
    let qualifyingRecord: String    // fastest qualifying lap all-time
    let qualifyingRecordHolder: String
    let qualifyingRecordYear: Int
    let latitude: Double
    let longitude: Double
}
