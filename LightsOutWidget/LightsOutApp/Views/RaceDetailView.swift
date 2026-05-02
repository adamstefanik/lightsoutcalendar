import SwiftUI

struct RaceDetailView: View {
    let race: Race
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    var onBack: (() -> Void)? = nil
    var onForward: (() -> Void)? = nil
    var onRefresh: (() async -> Void)? = nil
    @Binding var deepLinkedSession: Session?
    @Binding var navigationPath: NavigationPath

    @StateObject private var settings = SettingsManager.shared

    @State private var weatherState: WeatherLoadState = .loading
    @State private var raceResults: [DriverResult] = []
    @State private var resultsSessionName: String = ""

    // Define a proper PreferenceKey for the scroll offset.
    private struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    @State private var scrollOffset: CGFloat = 0
    @State private var screenWidth: CGFloat = 0

    private var circuitInfo: CircuitInfo? {
        CircuitDatabase.info(for: race.shortName)
    }

    private var resultsDisplayType: SessionDisplayType {
        switch resultsSessionName {
        case "GRAND PRIX": return .race
        case "SPRINT": return .sprint
        case "PRACTICE 1", "PRACTICE 2", "PRACTICE 3": return .practice
        default: return .timing
        }
    }

    private var isWeatherAvailable: Bool {
        guard !race.isCompleted else { return false }
        let daysUntilWeekend = race.weekendStart.timeIntervalSinceNow / 86400
        return daysUntilWeekend <= 5
    }

    var body: some View {
        // Main content
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                    }
                    .frame(height: 0)

                    RaceHeaderView(race: race)

                    // Divider
                    Rectangle()
                        .fill(Color.f1Divider)
                        .frame(height: 1)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)

                    // Session rows
                    VStack(spacing: 0) {
                        ForEach(Array(race.sessions.enumerated()), id: \.offset) { _, session in
                            AppSessionRowView(session: session, isCanceled: race.isCanceled)
                        }
                    }

                    // Race results
                    if !raceResults.isEmpty {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)
                            .padding(.top, 10)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)

                        if settings.hideSpoilers {
                            SpoilerCoverView()
                        } else {
                            RaceResultsView(
                                results: raceResults,
                                displayType: resultsDisplayType,
                                sessionName: resultsSessionName
                            )
                        }
                    }

                    // Weather
                    if isWeatherAvailable {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)
                            .padding(.top, 10)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)

                        WeatherSectionView(state: weatherState, temperatureUnit: settings.temperatureUnit)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }

                    // Circuit info
                    if let info = circuitInfo {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)
                            .padding(.top, 10)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)

                        CircuitInfoView(circuit: info, raceName: race.name)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                }
            }
            .tint(.clear)
            .scrollContentBackground(.hidden)
            .background(Color("f1Background"))
            .coordinateSpace(name: "scroll")
            .refreshable {
                #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                #endif
                await onRefresh?()
                weatherState = .loading
                raceResults = []
                await loadWeather()
                await loadResults()
            }
            .task(id: race.sessionKeyHash) {
                weatherState = .loading
                raceResults = []
                await loadWeather()
                await loadResults()
            }

            // Custom Top Bar with Gradient Fade
            HStack {
                #if os(iOS)
                Button { onBack?() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(canGoBack ? .white : .f1SecondaryText.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular.interactive(), in: Circle())
                        .contentShape(Circle())
                }
                .disabled(!canGoBack)
                #endif

                Spacer()

                Text("RACE \(race.round)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                #if os(iOS)
                Button { onForward?() } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(canGoForward ? .white : .f1SecondaryText.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular.interactive(), in: Circle())
                        .contentShape(Circle())
                }
                .disabled(!canGoForward)
                #endif
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 0)
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

    // MARK: - Weather Loading

    private func loadWeather() async {
        guard isWeatherAvailable, let info = circuitInfo else {
            weatherState = .error
            return
        }

        weatherState = .loading
        let forecasts = await WeatherService.shared.fetchForecast(
            latitude: info.latitude,
            longitude: info.longitude,
            weekendStart: race.weekendStart,
            raceDate: race.raceDate,
            sessions: race.sessions
        )
        if !forecasts.isEmpty {
            weatherState = .loaded(forecasts)
        } else {
            weatherState = .error
        }
    }

    // MARK: - Results Loading

    private func loadResults() async {
        let practiceSessions: Set<String> = ["PRACTICE 1", "PRACTICE 2", "PRACTICE 3"]
        let completedSessions = race.sessions.filter {
            guard let end = $0.endDate else { return false }
            return end < Date() && $0.sessionKey != nil && !practiceSessions.contains($0.name)
        }
        guard !completedSessions.isEmpty else { return }

        let targetSession: Session
        if race.isCompleted, let gp = completedSessions.last(where: { $0.name == "GRAND PRIX" }) {
            targetSession = gp
        } else {
            targetSession = completedSessions.last!
        }

        guard let key = targetSession.sessionKey else { return }
        resultsSessionName = targetSession.name
        raceResults = await F1APIService.shared.fetchResults(for: key, sessionType: apiSessionType(for: targetSession.name))
    }

    private func apiSessionType(for name: String) -> F1APIService.SessionType {
        switch name {
        case "GRAND PRIX": return .race
        case "SPRINT": return .sprint
        case "PRACTICE 1", "PRACTICE 2", "PRACTICE 3": return .practice
        case "SPRINT QUALIFYING": return .sprintTiming
        default: return .timing
        }
    }
}
