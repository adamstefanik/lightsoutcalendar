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

        Race(id: 1, round: 1,
             name: "Australian Grand Prix", shortName: "AUS", city: "Melbourne",
             circuit: "Albert Park Circuit", country: "Australia", countryFlag: "🇦🇺",
             raceDate: date(2026,3,8), qualifyingDate: date(2026,3,7),
             weekendStart: date(2026,3,6), sprint: false),

        Race(id: 2, round: 2,
             name: "Chinese Grand Prix", shortName: "CHN", city: "Shanghai",
             circuit: "Shanghai International Circuit", country: "China", countryFlag: "🇨🇳",
             raceDate: date(2026,3,15), qualifyingDate: date(2026,3,14),
             weekendStart: date(2026,3,13), sprint: true),

        Race(id: 3, round: 3,
             name: "Japanese Grand Prix", shortName: "JPN", city: "Suzuka",
             circuit: "Suzuka International Racing Course", country: "Japan", countryFlag: "🇯🇵 ",
             raceDate: date(2026,3,29), qualifyingDate: date(2026,3,28),
             weekendStart: date(2026,3,27), sprint: false),

        Race(id: 4, round: 4,
             name: "Bahrain Grand Prix", shortName: "BHR", city: "Sakhir",
             circuit: "Bahrain International Circuit", country: "Bahrain", countryFlag: "🇧🇭",
             raceDate: date(2026,5,3), qualifyingDate: date(2026,5,2),
             weekendStart: date(2026,5,1), sprint: false),

        Race(id: 5, round: 5,
             name: "Saudi Arabian Grand Prix", shortName: "SAU", city: "Jeddah",
             circuit: "Jeddah Corniche Circuit", country: "Saudi Arabia", countryFlag: "🇸🇦",
             raceDate: date(2026,5,17), qualifyingDate: date(2026,5,16),
             weekendStart: date(2026,5,15), sprint: false),
        
        Race(id: 6, round: 6,
             name: "Miami Grand Prix", shortName: "MIA", city: "Miami",
             circuit: "Miami International Autodrome", country: "USA", countryFlag: "🇺🇸",
             raceDate: date(2026,5,31), qualifyingDate: date(2026,5,30),
             weekendStart: date(2026,5,29), sprint: true),

        Race(id: 7, round: 7,
             name: "Emilia Romagna Grand Prix", shortName: "IMO", city: "Imola",
             circuit: "Autodromo Enzo e Dino Ferrari", country: "Italy", countryFlag: "🇮🇹",
             raceDate: date(2026,6,21), qualifyingDate: date(2026,6,20),
             weekendStart: date(2026,6,19), sprint: false),

        Race(id: 8, round: 8,
             name: "Monaco Grand Prix", shortName: "MON", city: "Monte Carlo",
             circuit: "Circuit de Monaco", country: "Monaco", countryFlag: "🇲🇨",
             raceDate: date(2026,6,28), qualifyingDate: date(2026,6,27),
             weekendStart: date(2026,6,26), sprint: false),

        Race(id: 9, round: 9,
             name: "Spanish Grand Prix", shortName: "ESP", city: "Barcelona",
             circuit: "Circuit de Barcelona-Catalunya", country: "Spain", countryFlag: "🇪🇸",
             raceDate: date(2026,7,5), qualifyingDate: date(2026,7,4),
             weekendStart: date(2026,7,3), sprint: false),

        Race(id: 10, round: 10,
             name: "Canadian Grand Prix", shortName: "CAN", city: "Montreal",
             circuit: "Circuit Gilles Villeneuve", country: "Canada", countryFlag: "🇨🇦",
             raceDate: date(2026,7,19), qualifyingDate: date(2026,7,18),
             weekendStart: date(2026,7,17), sprint: false),

        Race(id: 11, round: 11,
             name: "Austrian Grand Prix", shortName: "AUT", city: "Spielberg",
             circuit: "Red Bull Ring", country: "Austria", countryFlag: "🇦🇹",
             raceDate: date(2026,7,26), qualifyingDate: date(2026,7,25),
             weekendStart: date(2026,7,24), sprint: false),

        Race(id: 12, round: 12,
             name: "British Grand Prix", shortName: "GBR", city: "Silverstone",
             circuit: "Silverstone Circuit", country: "Great Britain", countryFlag: "🇬🇧",
             raceDate: date(2026,8,2), qualifyingDate: date(2026,8,1),
             weekendStart: date(2026,7,31), sprint: false),

        Race(id: 13, round: 13,
             name: "Belgian Grand Prix", shortName: "BEL", city: "Spa",
             circuit: "Circuit de Spa-Francorchamps", country: "Belgium", countryFlag: "🇧🇪",
             raceDate: date(2026,8,30), qualifyingDate: date(2026,8,29),
             weekendStart: date(2026,8,28), sprint: true),

        Race(id: 14, round: 14,
             name: "Dutch Grand Prix", shortName: "NED", city: "Zandvoort",
             circuit: "Circuit Zandvoort", country: "Netherlands", countryFlag: "🇳🇱",
             raceDate: date(2026,9,6), qualifyingDate: date(2026,9,5),
             weekendStart: date(2026,9,4), sprint: false),

        Race(id: 15, round: 15,
             name: "Italian Grand Prix", shortName: "ITA", city: "Monza",
             circuit: "Autodromo Nazionale Monza", country: "Italy", countryFlag: "🇮🇹",
             raceDate: date(2026,9,13), qualifyingDate: date(2026,9,12),
             weekendStart: date(2026,9,11), sprint: false),

        Race(id: 16, round: 16,
             name: "Azerbaijan Grand Prix", shortName: "AZE", city: "Baku",
             circuit: "Baku City Circuit", country: "Azerbaijan", countryFlag: "🇦🇿",
             raceDate: date(2026,9,27), qualifyingDate: date(2026,9,26),
             weekendStart: date(2026,9,25), sprint: false),

        Race(id: 17, round: 17,
             name: "Singapore Grand Prix", shortName: "SGP", city: "Singapore",
             circuit: "Marina Bay Street Circuit", country: "Singapore", countryFlag: "🇸🇬",
             raceDate: date(2026,10,4), qualifyingDate: date(2026,10,3),
             weekendStart: date(2026,10,2), sprint: false),

        Race(id: 18, round: 18,
             name: "United States Grand Prix", shortName: "USA", city: "Austin",
             circuit: "Circuit of the Americas", country: "USA", countryFlag: "🇺🇸",
             raceDate: date(2026,10,18), qualifyingDate: date(2026,10,17),
             weekendStart: date(2026,10,16), sprint: true),

        Race(id: 19, round: 19,
             name: "Mexico City Grand Prix", shortName: "MEX", city: "Mexico City",
             circuit: "Autodromo Hermanos Rodriguez", country: "Mexico", countryFlag: "🇲🇽",
             raceDate: date(2026,10,25), qualifyingDate: date(2026,10,24),
             weekendStart: date(2026,10,23), sprint: false),

        Race(id: 20, round: 20,
             name: "São Paulo Grand Prix", shortName: "BRA", city: "São Paulo",
             circuit: "Autodromo Jose Carlos Pace", country: "Brazil", countryFlag: "🇧🇷",
             raceDate: date(2026,11,8), qualifyingDate: date(2026,11,7),
             weekendStart: date(2026,11,6), sprint: true),

        Race(id: 21, round: 21,
             name: "Las Vegas Grand Prix", shortName: "LVG", city: "Las Vegas",
             circuit: "Las Vegas Strip Circuit", country: "USA", countryFlag: "🇺🇸",
             raceDate: date(2026,11,21), qualifyingDate: date(2026,11,20),
             weekendStart: date(2026,11,19), sprint: false),

        Race(id: 22, round: 22,
             name: "Qatar Grand Prix", shortName: "QAT", city: "Lusail",
             circuit: "Lusail International Circuit", country: "Qatar", countryFlag: "🇶🇦",
             raceDate: date(2026,11,29), qualifyingDate: date(2026,11,28),
             weekendStart: date(2026,11,27), sprint: true),

        Race(id: 23, round: 23,
             name: "Abu Dhabi Grand Prix", shortName: "ABU", city: "Abu Dhabi",
             circuit: "Yas Marina Circuit", country: "UAE", countryFlag: "🇦🇪",
             raceDate: date(2026,12,6), qualifyingDate: date(2026,12,5),
             weekendStart: date(2026,12,4), sprint: false),
    ]

}
