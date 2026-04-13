import SwiftUI

extension Color {
    static let f1Red = Color(red: 0.90, green: 0.04, blue: 0.04)

    // f1Background, f1Surface, f1Text, f1SecondaryText, f1Border, f1Divider
    // are auto-generated from Assets.xcassets color sets

    // Legacy (kept for fallback)
    static let f1Dark   = Color(red: 0.08, green: 0.08, blue: 0.09)
    static let f1Carbon = Color(red: 0.18, green: 0.18, blue: 0.20)
    static let f1Gray   = Color(red: 0.55, green: 0.55, blue: 0.58)
    static let f1Gold   = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let f1Silver = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let f1Bronze = Color(red: 0.80, green: 0.50, blue: 0.20)
    static let f1Purple = Color(red: 0.61, green: 0.19, blue: 1.0)
}

// MARK: - Team Colors & Abbreviations

struct TeamStyle {
    let abbreviation: String
    let color: Color

    /// Looks up team style by team name (as returned from OpenF1 API)
    static func from(team: String) -> TeamStyle {
        let key = team.lowercased()
        for (pattern, style) in mapping {
            if key.contains(pattern) { return style }
        }
        return TeamStyle(abbreviation: "F1", color: .gray)
    }

    private static let mapping: [(String, TeamStyle)] = [
        ("red bull",      TeamStyle(abbreviation: "RBR", color: Color(red: 0.22, green: 0.33, blue: 0.72))),
        ("ferrari",       TeamStyle(abbreviation: "FER", color: Color(red: 0.93, green: 0.16, blue: 0.16))),
        ("mclaren",       TeamStyle(abbreviation: "MCL", color: Color(red: 1.00, green: 0.53, blue: 0.00))),
        ("mercedes",      TeamStyle(abbreviation: "MER", color: Color(red: 0.15, green: 0.82, blue: 0.78))),
        ("aston martin",  TeamStyle(abbreviation: "AMR", color: Color(red: 0.00, green: 0.51, blue: 0.38))),
        ("alpine",        TeamStyle(abbreviation: "ALP", color: Color(red: 0.00, green: 0.58, blue: 0.87))),
        ("williams",      TeamStyle(abbreviation: "WIL", color: Color(red: 0.00, green: 0.32, blue: 0.65))),
        ("racing bulls",  TeamStyle(abbreviation: "RCB", color: Color(red: 0.40, green: 0.47, blue: 0.80))),
        ("rb ",           TeamStyle(abbreviation: "RCB", color: Color(red: 0.40, green: 0.47, blue: 0.80))),
        ("haas",          TeamStyle(abbreviation: "HAA", color: Color(red: 0.70, green: 0.70, blue: 0.70))),
        ("sauber",        TeamStyle(abbreviation: "SAU", color: Color(red: 0.00, green: 0.56, blue: 0.22))),
        ("audi",          TeamStyle(abbreviation: "AUD", color: Color(red: 0.93, green: 0.16, blue: 0.16))),
        ("cadillac",      TeamStyle(abbreviation: "CAD", color: Color(red: 0.70, green: 0.70, blue: 0.70))),
    ]
}
