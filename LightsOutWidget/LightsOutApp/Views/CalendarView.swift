import SwiftUI

struct CalendarView: View {
    @ObservedObject var raceStore: RaceStore
    @State private var navigationPath = NavigationPath()

    private var races: [Race] { raceStore.races }
    private var nextRace: Race? { raceStore.nextRace }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
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
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color("f1Background"))
                    .onAppear {
                        if let next = nextRace {
                            proxy.scrollTo(next.id, anchor: .center)
                        }
                    }
                    .navigationDestination(for: Int.self) { raceId in
                        if let race = races.first(where: { $0.id == raceId }) {
                            RaceDetailView(race: race, deepLinkedSession: .constant(nil), navigationPath: $navigationPath)
                                .navigationTitle("RACE \(race.round)")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbarBackground(Color("f1Background"), for: .navigationBar)
                                .toolbarBackground(.visible, for: .navigationBar)
                        }
                    }
                    .navigationDestination(for: Session.self) { session in
                        SessionResultsLoader(session: session)
                    }
                }
                
                // Custom Top Bar with Gradient Fade
                HStack {
                    Spacer()
                    Text("2026 SEASON")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background {
                    VStack(spacing: 0) {
                        Color("f1Background")
                            .ignoresSafeArea(edges: .top)
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("f1Background"),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 40)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Preview

#Preview {
    CalendarView(raceStore: RaceStore())
        .preferredColorScheme(.dark)
}
