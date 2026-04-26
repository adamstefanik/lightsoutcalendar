import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Int
    @Binding var deepLinkedRaceId: Int?
    @Binding var deepLinkedSession: Session?
    @ObservedObject var raceStore: RaceStore

    @State private var currentRaceIndex: Int?
    @State private var slideForward: Bool = true
    @State private var isTransitioning: Bool = false

    private var raceIndex: Int {
        if let idx = currentRaceIndex { return idx }
        let nextIdx = raceStore.races.firstIndex { !$0.isCompleted }
        return nextIdx ?? 0
    }

    private var currentRace: Race {
        raceStore.races[raceIndex]
    }

    private func navigate(to newIndex: Int, forward: Bool) {
        guard !isTransitioning,
              newIndex >= 0, newIndex < raceStore.races.count else { return }
        isTransitioning = true
        slideForward = forward
        // Defer .id() change so SwiftUI commits slideForward first → correct removal direction.
        Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentRaceIndex = newIndex
            } completion: {
                isTransitioning = false
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ZStack {
                RaceDetailView(
                    race: currentRace,
                    canGoBack: raceIndex > 0,
                    canGoForward: raceIndex < raceStore.races.count - 1,
                    onBack: { navigate(to: raceIndex - 1, forward: false) },
                    onForward: { navigate(to: raceIndex + 1, forward: true) },
                    onRefresh: { await raceStore.loadRaces() },
                    deepLinkedSession: $deepLinkedSession
                )
                .id(currentRace.id)
                .transition(slideForward
                    ? .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                    : .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
                )
            }
            .tabItem {
                Image(systemName: "flag.checkered")
                Text("Race")
            }
            .tag(0)

            CalendarView(raceStore: raceStore)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)

            SettingsView(raceStore: raceStore)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(Color.f1Red)
        .preferredColorScheme(.dark)
        .onChange(of: deepLinkedRaceId) { _, raceId in
            guard let raceId,
                  let index = raceStore.races.firstIndex(where: { $0.id == raceId }) else { return }
            currentRaceIndex = index
            deepLinkedRaceId = nil
        }
    }
}

#Preview {
    ContentView(selectedTab: .constant(0), deepLinkedRaceId: .constant(nil), deepLinkedSession: .constant(nil), raceStore: RaceStore())
}
