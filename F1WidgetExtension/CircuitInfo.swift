import Foundation

struct CircuitInfo {
    let circuitId: String       // matches Race.shortName
    let length: String          // "6.174 km"
    let turns: Int              // 27
    let lapRecord: String       // "1:30.734"
    let lapRecordHolder: String // "Lewis Hamilton"
    let lapRecordYear: Int      // 2021
    let latitude: Double        // for weather API
    let longitude: Double       // for weather API
}
