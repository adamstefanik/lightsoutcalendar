import SwiftUI

@main
struct F1CalendarWidgetApp: App {
    @State private var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "f1calendar",
              url.host == "race" else { return }
        selectedTab = 0
    }
}
