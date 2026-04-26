import SwiftUI

struct CalendarView: View {
    @ObservedObject var raceStore: RaceStore

    private var races: [Race] { raceStore.races }
    private var nextRace: Race? { raceStore.nextRace }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // Race list
                        ForEach(races) { race in
                            NavigationLink(value: race.id) {
                                CalendarRowView(
                                    race: race,
                                    isNextRace: race.id == nextRace?.id
                                )
                            }
                            .buttonStyle(.plain)
                            .id(race.id)

                            if race.id != races.last?.id {
                                Rectangle()
                                    .fill(Color.f1Divider)
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                .background(Color("f1Background"))
                .navigationTitle("2026 SEASON")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .onAppear {
                    if let next = nextRace {
                        proxy.scrollTo(next.id, anchor: .center)
                    }
                }
                .navigationDestination(for: Int.self) { raceId in
                    if let race = races.first(where: { $0.id == raceId }) {
                        RaceDetailView(race: race, deepLinkedSession: .constant(nil))
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CalendarView(raceStore: RaceStore())
        .preferredColorScheme(.dark)
}
