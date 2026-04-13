import Foundation

struct F1Calendar {

    // Cached API races (set by widget provider after fetch)
    static var cachedRaces: [Race]?

    // Use API races if available, otherwise fallback
    static var races: [Race] {
        cachedRaces ?? fallbackRaces
    }

    static var nextRace: Race? { races.first { !$0.isCompleted } }
    static var upcomingRaces: [Race] { races.filter { !$0.isCompleted } }

    // MARK: - Fallback (hardcoded)

    private static func date(_ y: Int, _ m: Int, _ d: Int, hour: Int = 13) -> Date {
        var c = DateComponents()
        c.year = y; c.month = m; c.day = d; c.hour = hour
        return Calendar(identifier: .gregorian).date(from: c)!
    }

    static let fallbackRaces: [Race] = [

        // R1 — Mar 6-8
        Race(id: 1, round: 1,
             name: "Australian Grand Prix", shortName: "AUS", city: "Melbourne",
             circuit: "Albert Park Circuit", country: "Australia", countryFlag: "🇦🇺",
             raceDate: date(2026,3,8), qualifyingDate: date(2026,3,7),
             weekendStart: date(2026,3,6), sprint: false),

        // R2 — Mar 13-15 (Sprint)
        Race(id: 2, round: 2,
             name: "Chinese Grand Prix", shortName: "CHN", city: "Shanghai",
             circuit: "Shanghai International Circuit", country: "China", countryFlag: "🇨🇳",
             raceDate: date(2026,3,15), qualifyingDate: date(2026,3,14),
             weekendStart: date(2026,3,13), sprint: true),

        // R3 — Mar 27-29
        Race(id: 3, round: 3,
             name: "Japanese Grand Prix", shortName: "JPN", city: "Suzuka",
             circuit: "Suzuka International Racing Course", country: "Japan", countryFlag: "🇯🇵",
             raceDate: date(2026,3,29), qualifyingDate: date(2026,3,28),
             weekendStart: date(2026,3,27), sprint: false),

        // R4 — May 1-3 (Sprint)
        Race(id: 4, round: 4,
             name: "Miami Grand Prix", shortName: "MIA", city: "Miami",
             circuit: "Miami International Autodrome", country: "USA", countryFlag: "🇺🇸",
             raceDate: date(2026,5,3), qualifyingDate: date(2026,5,2),
             weekendStart: date(2026,5,1), sprint: true),

        // R5 — May 22-24 (Sprint)
        Race(id: 5, round: 5,
             name: "Canadian Grand Prix", shortName: "CAN", city: "Montreal",
             circuit: "Circuit Gilles Villeneuve", country: "Canada", countryFlag: "🇨🇦",
             raceDate: date(2026,5,24), qualifyingDate: date(2026,5,23),
             weekendStart: date(2026,5,22), sprint: true),

        // R6 — Jun 5-7
        Race(id: 6, round: 6,
             name: "Monaco Grand Prix", shortName: "MON", city: "Monte Carlo",
             circuit: "Circuit de Monaco", country: "Monaco", countryFlag: "🇲🇨",
             raceDate: date(2026,6,7), qualifyingDate: date(2026,6,6),
             weekendStart: date(2026,6,5), sprint: false),

        // R7 — Jun 12-14
        Race(id: 7, round: 7,
             name: "Barcelona-Catalunya Grand Prix", shortName: "ESP", city: "Barcelona",
             circuit: "Circuit de Barcelona-Catalunya", country: "Spain", countryFlag: "🇪🇸",
             raceDate: date(2026,6,14), qualifyingDate: date(2026,6,13),
             weekendStart: date(2026,6,12), sprint: false),

        // R8 — Jun 26-28
        Race(id: 8, round: 8,
             name: "Austrian Grand Prix", shortName: "AUT", city: "Spielberg",
             circuit: "Red Bull Ring", country: "Austria", countryFlag: "🇦🇹",
             raceDate: date(2026,6,28), qualifyingDate: date(2026,6,27),
             weekendStart: date(2026,6,26), sprint: false),

        // R9 — Jul 3-5 (Sprint)
        Race(id: 9, round: 9,
             name: "British Grand Prix", shortName: "GBR", city: "Silverstone",
             circuit: "Silverstone Circuit", country: "Great Britain", countryFlag: "🇬🇧",
             raceDate: date(2026,7,5), qualifyingDate: date(2026,7,4),
             weekendStart: date(2026,7,3), sprint: true),

        // R10 — Jul 17-19
        Race(id: 10, round: 10,
             name: "Belgian Grand Prix", shortName: "BEL", city: "Spa",
             circuit: "Circuit de Spa-Francorchamps", country: "Belgium", countryFlag: "🇧🇪",
             raceDate: date(2026,7,19), qualifyingDate: date(2026,7,18),
             weekendStart: date(2026,7,17), sprint: false),

        // R11 — Jul 24-26
        Race(id: 11, round: 11,
             name: "Hungarian Grand Prix", shortName: "HUN", city: "Budapest",
             circuit: "Hungaroring", country: "Hungary", countryFlag: "🇭🇺",
             raceDate: date(2026,7,26), qualifyingDate: date(2026,7,25),
             weekendStart: date(2026,7,24), sprint: false),

        // R12 — Aug 21-23 (Sprint)
        Race(id: 12, round: 12,
             name: "Dutch Grand Prix", shortName: "NED", city: "Zandvoort",
             circuit: "Circuit Zandvoort", country: "Netherlands", countryFlag: "🇳🇱",
             raceDate: date(2026,8,23), qualifyingDate: date(2026,8,22),
             weekendStart: date(2026,8,21), sprint: true),

        // R13 — Sep 4-6
        Race(id: 13, round: 13,
             name: "Italian Grand Prix", shortName: "ITA", city: "Monza",
             circuit: "Autodromo Nazionale Monza", country: "Italy", countryFlag: "🇮🇹",
             raceDate: date(2026,9,6), qualifyingDate: date(2026,9,5),
             weekendStart: date(2026,9,4), sprint: false),

        // R14 — Sep 11-13
        Race(id: 14, round: 14,
             name: "Spanish Grand Prix", shortName: "MAD", city: "Madrid",
             circuit: "Circuito de Madrid", country: "Spain", countryFlag: "🇪🇸",
             raceDate: date(2026,9,13), qualifyingDate: date(2026,9,12),
             weekendStart: date(2026,9,11), sprint: false),

        // R15 — Sep 24-26 (Saturday race)
        Race(id: 15, round: 15,
             name: "Azerbaijan Grand Prix", shortName: "AZE", city: "Baku",
             circuit: "Baku City Circuit", country: "Azerbaijan", countryFlag: "🇦🇿",
             raceDate: date(2026,9,26), qualifyingDate: date(2026,9,25),
             weekendStart: date(2026,9,24), sprint: false),

        // R16 — Oct 9-11 (Sprint)
        Race(id: 16, round: 16,
             name: "Singapore Grand Prix", shortName: "SGP", city: "Singapore",
             circuit: "Marina Bay Street Circuit", country: "Singapore", countryFlag: "🇸🇬",
             raceDate: date(2026,10,11), qualifyingDate: date(2026,10,10),
             weekendStart: date(2026,10,9), sprint: true),

        // R17 — Oct 23-25
        Race(id: 17, round: 17,
             name: "United States Grand Prix", shortName: "USA", city: "Austin",
             circuit: "Circuit of the Americas", country: "USA", countryFlag: "🇺🇸",
             raceDate: date(2026,10,25), qualifyingDate: date(2026,10,24),
             weekendStart: date(2026,10,23), sprint: false),

        // R18 — Oct 30-Nov 1
        Race(id: 18, round: 18,
             name: "Mexico City Grand Prix", shortName: "MEX", city: "Mexico City",
             circuit: "Autodromo Hermanos Rodriguez", country: "Mexico", countryFlag: "🇲🇽",
             raceDate: date(2026,11,1), qualifyingDate: date(2026,10,31),
             weekendStart: date(2026,10,30), sprint: false),

        // R19 — Nov 6-8
        Race(id: 19, round: 19,
             name: "São Paulo Grand Prix", shortName: "BRA", city: "São Paulo",
             circuit: "Autodromo Jose Carlos Pace", country: "Brazil", countryFlag: "🇧🇷",
             raceDate: date(2026,11,8), qualifyingDate: date(2026,11,7),
             weekendStart: date(2026,11,6), sprint: false),

        // R20 — Nov 19-21 (Saturday race)
        Race(id: 20, round: 20,
             name: "Las Vegas Grand Prix", shortName: "LVG", city: "Las Vegas",
             circuit: "Las Vegas Strip Circuit", country: "USA", countryFlag: "🇺🇸",
             raceDate: date(2026,11,21), qualifyingDate: date(2026,11,20),
             weekendStart: date(2026,11,19), sprint: false),

        // R21 — Nov 27-29
        Race(id: 21, round: 21,
             name: "Qatar Grand Prix", shortName: "QAT", city: "Lusail",
             circuit: "Lusail International Circuit", country: "Qatar", countryFlag: "🇶🇦",
             raceDate: date(2026,11,29), qualifyingDate: date(2026,11,28),
             weekendStart: date(2026,11,27), sprint: false),

        // R22 — Dec 4-6
        Race(id: 22, round: 22,
             name: "Abu Dhabi Grand Prix", shortName: "ABU", city: "Abu Dhabi",
             circuit: "Yas Marina Circuit", country: "UAE", countryFlag: "🇦🇪",
             raceDate: date(2026,12,6), qualifyingDate: date(2026,12,5),
             weekendStart: date(2026,12,4), sprint: false),
    ]

}
