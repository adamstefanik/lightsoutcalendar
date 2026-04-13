import Foundation

struct CircuitDatabase {
    static let circuits: [CircuitInfo] = [
        CircuitInfo(circuitId: "AUS", length: "5.278 km", turns: 14, lapRecord: "1:19.813", lapRecordHolder: "Charles Leclerc",      lapRecordYear: 2024, latitude: -37.8497, longitude: 144.9680),
        CircuitInfo(circuitId: "BHR", length: "5.412 km", turns: 15, lapRecord: "1:31.447", lapRecordHolder: "Pedro de la Rosa",     lapRecordYear: 2005, latitude:  26.0325, longitude:  50.5106),
        CircuitInfo(circuitId: "SAU", length: "6.174 km", turns: 27, lapRecord: "1:30.734", lapRecordHolder: "Lewis Hamilton",       lapRecordYear: 2021, latitude:  21.6319, longitude:  39.1044),
        CircuitInfo(circuitId: "CHN", length: "5.451 km", turns: 16, lapRecord: "1:32.238", lapRecordHolder: "Michael Schumacher",   lapRecordYear: 2004, latitude:  31.3389, longitude: 121.2198),
        CircuitInfo(circuitId: "JPN", length: "5.807 km", turns: 18, lapRecord: "1:30.965", lapRecordHolder: "Kimi Antonelli",       lapRecordYear: 2025, latitude:  34.8431, longitude: 136.5407),
        CircuitInfo(circuitId: "MIA", length: "5.412 km", turns: 19, lapRecord: "1:29.708", lapRecordHolder: "Max Verstappen",       lapRecordYear: 2023, latitude:  25.9581, longitude: -80.2389),
        CircuitInfo(circuitId: "MON", length: "3.337 km", turns: 19, lapRecord: "1:12.909", lapRecordHolder: "Lewis Hamilton",       lapRecordYear: 2021, latitude:  43.7347, longitude:   7.4206),
        CircuitInfo(circuitId: "ESP", length: "4.657 km", turns: 16, lapRecord: "1:15.743", lapRecordHolder: "Oscar Piastri",        lapRecordYear: 2025, latitude:  41.5700, longitude:   2.2611),
        CircuitInfo(circuitId: "MAD", length: "5.473 km", turns: 20, lapRecord: "—",      lapRecordHolder: "—",                    lapRecordYear: 2026, latitude:  40.4652, longitude:  -3.6163),
        CircuitInfo(circuitId: "CAN", length: "4.361 km", turns: 14, lapRecord: "1:13.078", lapRecordHolder: "Valtteri Bottas",      lapRecordYear: 2019, latitude:  45.5000, longitude: -73.5228),
        CircuitInfo(circuitId: "AUT", length: "4.318 km", turns: 10, lapRecord: "1:05.619", lapRecordHolder: "Carlos Sainz",         lapRecordYear: 2020, latitude:  47.2197, longitude:  14.7647),
        CircuitInfo(circuitId: "GBR", length: "5.891 km", turns: 18, lapRecord: "1:27.097", lapRecordHolder: "Max Verstappen",       lapRecordYear: 2020, latitude:  52.0786, longitude:  -1.0169),
        CircuitInfo(circuitId: "HUN", length: "4.381 km", turns: 14, lapRecord: "1:16.627", lapRecordHolder: "Lewis Hamilton",       lapRecordYear: 2020, latitude:  47.5789, longitude:  19.2486),
        CircuitInfo(circuitId: "BEL", length: "7.004 km", turns: 19, lapRecord: "1:44.701", lapRecordHolder: "Sergio Perez",         lapRecordYear: 2024, latitude:  50.4372, longitude:   5.9714),
        CircuitInfo(circuitId: "NED", length: "4.259 km", turns: 14, lapRecord: "1:11.097", lapRecordHolder: "Lewis Hamilton",       lapRecordYear: 2021, latitude:  52.3888, longitude:   4.5409),
        CircuitInfo(circuitId: "ITA", length: "5.793 km", turns: 11, lapRecord: "1:20.901", lapRecordHolder: "Lando Norris",          lapRecordYear: 2025, latitude:  45.6156, longitude:   9.2811),
        CircuitInfo(circuitId: "AZE", length: "6.003 km", turns: 20, lapRecord: "1:43.009", lapRecordHolder: "Charles Leclerc",      lapRecordYear: 2019, latitude:  40.3725, longitude:  49.8533),
        CircuitInfo(circuitId: "SGP", length: "4.940 km", turns: 19, lapRecord: "1:33.808", lapRecordHolder: "Lewis Hamilton",       lapRecordYear: 2025, latitude:   1.2914, longitude: 103.8636),
        CircuitInfo(circuitId: "USA", length: "5.513 km", turns: 20, lapRecord: "1:36.169", lapRecordHolder: "Charles Leclerc",      lapRecordYear: 2019, latitude:  30.1328, longitude: -97.6411),
        CircuitInfo(circuitId: "MEX", length: "4.304 km", turns: 17, lapRecord: "1:17.774", lapRecordHolder: "Valtteri Bottas",      lapRecordYear: 2021, latitude:  19.4042, longitude: -99.0907),
        CircuitInfo(circuitId: "BRA", length: "4.309 km", turns: 15, lapRecord: "1:10.540", lapRecordHolder: "Valtteri Bottas",      lapRecordYear: 2018, latitude: -23.7036, longitude: -46.6997),
        CircuitInfo(circuitId: "LVG", length: "6.201 km", turns: 17, lapRecord: "1:33.365", lapRecordHolder: "Max Verstappen",       lapRecordYear: 2025, latitude:  36.1147, longitude: -115.1728),
        CircuitInfo(circuitId: "QAT", length: "5.380 km", turns: 16, lapRecord: "1:22.384", lapRecordHolder: "Lando Norris",          lapRecordYear: 2024, latitude:  25.4900, longitude:  51.4542),
        CircuitInfo(circuitId: "ABU", length: "5.281 km", turns: 16, lapRecord: "1:25.637", lapRecordHolder: "Kevin Magnussen",       lapRecordYear: 2024, latitude:  24.4672, longitude:  54.6031),
    ]

    static func info(for shortName: String) -> CircuitInfo? {
        circuits.first { $0.circuitId == shortName }
    }
}
