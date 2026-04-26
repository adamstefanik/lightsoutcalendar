import SwiftUI
import Combine
import WidgetKit

@main
struct F1CalendarWidgetApp: App {
    @State private var selectedTab = 0
    @State private var deepLinkedRaceId: Int?
    @State private var deepLinkedSession: Session?
    @StateObject private var raceStore = RaceStore()
    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab, deepLinkedRaceId: $deepLinkedRaceId, deepLinkedSession: $deepLinkedSession, raceStore: raceStore)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .task {
                    await raceStore.loadRaces()
                    await scheduleNotificationsIfAllowed()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                #if os(iOS)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task {
                        await raceStore.loadRaces()
                        await scheduleNotificationsIfAllowed()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                #elseif os(macOS)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    Task {
                        await raceStore.loadRaces()
                        await scheduleNotificationsIfAllowed()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                #endif
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "lightsout" else { return }
        if url.host == "results" {
            let components = url.pathComponents.filter { $0 != "/" }
            if components.count >= 2,
               let sessionKey = Int(components[0]) {
                let sessionName = components[1].removingPercentEncoding ?? components[1]
                deepLinkedSession = Session(
                    name: sessionName,
                    day: "", time: "",
                    isHighlighted: false,
                    sessionKey: sessionKey
                )
            }
        } else if url.host == "race" {
            selectedTab = 0
            if let idString = url.pathComponents.last,
               let raceId = Int(idString) {
                deepLinkedRaceId = raceId
            }
        }
    }

    private func scheduleNotificationsIfAllowed() async {
        let granted = await NotificationManager.shared.requestPermission()
        if granted {
            NotificationManager.shared.scheduleNotifications(
                for: raceStore.races,
                settings: SettingsManager.shared
            )
        }
    }
}

// MARK: - Race Store

final class RaceStore: ObservableObject {
    @Published var races: [Race] = F1Calendar.fallbackRaces
    @Published var isLoading = true
    var nextRace: Race? { races.first { !$0.isCompleted } }

    @MainActor
    func loadRaces() async {
        let apiRaces = await F1APIService.shared.fetchRaces()
        if !apiRaces.isEmpty {
            races = apiRaces
            F1Calendar.cachedRaces = apiRaces
        }
        isLoading = false
    }
}
