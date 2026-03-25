import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            RaceDetailView(race: F1Calendar.nextRace ?? F1Calendar.fallbackRaces[0])
                .tabItem {
                    Image(systemName: "car.fill")
                    Text("Race")
                }
                .tag(0)

            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(Color.f1Red)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView(selectedTab: .constant(0))
}
