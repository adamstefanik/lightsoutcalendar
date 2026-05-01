import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Int
    @Binding var deepLinkedRaceId: Int?
    @Binding var deepLinkedSession: Session?
    @ObservedObject var raceStore: RaceStore

    @State private var currentRaceIndex: Int?
    @State private var navigationPath = NavigationPath()

    private var raceIndex: Int {
        if let idx = currentRaceIndex { return idx }
        let nextIdx = raceStore.races.firstIndex { !$0.isCompleted }
        return nextIdx ?? 0
    }

    var body: some View {
        ZStack {
            Color("f1Background")
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                NavigationStack(path: $navigationPath) {
                    ZStack {
                        Color("f1Background")
                            .ignoresSafeArea()

                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 0) {
                                ForEach(raceStore.races.indices, id: \.self) { idx in
                                    RaceDetailView(
                                        race: raceStore.races[idx],
                                        canGoBack: idx > 0,
                                        canGoForward: idx < raceStore.races.count - 1,
                                        onBack: { withAnimation { currentRaceIndex = idx - 1 } },
                                        onForward: { withAnimation { currentRaceIndex = idx + 1 } },
                                        onRefresh: { await raceStore.loadRaces() },
                                        deepLinkedSession: $deepLinkedSession,
                                        navigationPath: $navigationPath
                                    )
                                    .containerRelativeFrame(.horizontal)
                                    .id(idx)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: Binding(
                            get: { currentRaceIndex ?? raceIndex },
                            set: { if let v = $0 { currentRaceIndex = v } }
                        ))
                        .scrollIndicators(.hidden)
                        .ignoresSafeArea(.container, edges: .horizontal)
                    }
                    .navigationDestination(for: Session.self) { session in
                        SessionResultsLoader(session: session)
                    }
                }
                .tabItem {
                    Image(systemName: "flag.checkered")
                    Text("Race")
                }
                .tag(0)
                .toolbarBackground(Color("f1Background"), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)

                CalendarView(raceStore: raceStore)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                    .tag(1)
                    .toolbarBackground(Color("f1Background"), for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)

                SettingsView(raceStore: raceStore)
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .tag(2)
                    .toolbarBackground(Color("f1Background"), for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)
            }
            .tint(Color.f1Red)
        }
        .preferredColorScheme(.dark)
        .onChange(of: deepLinkedRaceId) { _, raceId in
            guard let raceId,
                  let index = raceStore.races.firstIndex(where: { $0.id == raceId }) else { return }
            currentRaceIndex = index
            deepLinkedRaceId = nil
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView(selectedTab: .constant(0), deepLinkedRaceId: .constant(nil), deepLinkedSession: .constant(nil), raceStore: RaceStore())
}

extension Array {
    subscript(safeIndex index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
