import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Race Detail")
                .foregroundColor(.f1Text)
                .tabItem {
                    Image(systemName: "car.fill")
                    Text("Race")
                }
                .tag(0)

            Text("Calendar")
                .foregroundColor(.f1Text)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)

            Text("Settings")
                .foregroundColor(.f1Text)
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
