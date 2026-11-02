//
//  F1CalendarWidgetTests.swift
//  F1CalendarWidgetTests
//
//  Created by Adam S. Štefánik on 17/03/2026.
//

#if DEBUG
import Testing
import Foundation
@testable import LightsOutCalendar

struct F1CalendarWidgetTests {

    @Test func testGrandPrixLiveDoesNotMarkRaceAsCompleted() async throws {
        let liveRace = Race.previewLiveGrandPrix

        // Grand Prix is live
        #expect(liveRace.isLive == true)
        #expect(liveRace.isCompleted == false)
        #expect(liveRace.isWeekendOver == false)
        #expect(liveRace.currentSessionBadge == "LIVE")
    }

    @Test func testCompletedRaceTransitionsAfterWeekendBuffer() async throws {
        let cal = Calendar.current
        let pastDate = Date().addingTimeInterval(-2 * 86400) // 2 days ago

        let completedRace = Race(
            id: 101, round: 1,
            name: "Past GP", shortName: "PST", city: "Past City",
            circuit: "Past Circuit", country: "Country", countryFlag: "🏁",
            raceDate: pastDate,
            qualifyingDate: cal.date(byAdding: .day, value: -1, to: pastDate)!,
            weekendStart: cal.date(byAdding: .day, value: -2, to: pastDate)!,
            sprint: false,
            apiSessions: [
                Session(name: "GRAND PRIX", day: "SUNDAY", time: "15:00", isHighlighted: true,
                        startDate: pastDate,
                        endDate: pastDate.addingTimeInterval(2 * 3600))
            ]
        )

        #expect(completedRace.isLive == false)
        #expect(completedRace.isCompleted == true)
        #expect(completedRace.isWeekendOver == true)
        #expect(completedRace.currentSessionBadge == "FINISHED")
    }

    @Test func testRaceImmediatelyAfterFinishStaysActiveUntilBuffer() async throws {
        let cal = Calendar.current
        let raceEnded30MinAgo = Date().addingTimeInterval(-30 * 60)
        let raceStarted2hAgo = raceEnded30MinAgo.addingTimeInterval(-2 * 3600)

        let justFinishedRace = Race(
            id: 102, round: 2,
            name: "Recent GP", shortName: "REC", city: "Recent City",
            circuit: "Recent Circuit", country: "Country", countryFlag: "🏁",
            raceDate: raceStarted2hAgo,
            qualifyingDate: cal.date(byAdding: .day, value: -1, to: raceStarted2hAgo)!,
            weekendStart: cal.date(byAdding: .day, value: -2, to: raceStarted2hAgo)!,
            sprint: false,
            apiSessions: [
                Session(name: "GRAND PRIX", day: "SUNDAY", time: "15:00", isHighlighted: true,
                        startDate: raceStarted2hAgo,
                        endDate: raceEnded30MinAgo)
            ]
        )

        #expect(justFinishedRace.isLive == false)
        #expect(justFinishedRace.isCompleted == true)
        // Weekend is NOT over yet because of the UX buffer (user can see results/podium)
        #expect(justFinishedRace.isWeekendOver == false)
        #expect(justFinishedRace.currentSessionBadge == "FINISHED")
    }
}
#endif
