import SwiftUI

struct RaceDetailView: View {
    let race: Race
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    var onBack: (() -> Void)? = nil
    var onForward: (() -> Void)? = nil
    var onRefresh: (() async -> Void)? = nil
    @Binding var deepLinkedSession: Session?

    @StateObject private var settings = SettingsManager.shared
    @State private var navigationPath = NavigationPath()

    @State private var weatherState: WeatherLoadState = .loading
    @State private var raceResults: [DriverResult] = []
    @State private var resultsSessionName: String = ""
    @State private var screenWidth: CGFloat = 393

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
        // OWM free tier returns 5-day / 120h forecast. Fetch as soon as the
        // weekend Friday is within that window — partial days appear first,
        // full Fri/Sat/Sun coverage typically from ~3 days before the race.
        let daysUntilWeekend = race.weekendStart.timeIntervalSinceNow / 86400
        return daysUntilWeekend <= 5
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Navigation arrows + Header (swipeable)
                    VStack(spacing: 0) {
                        if canGoBack || canGoForward {
                            ZStack {
                                Text("RACE \(race.round)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.f1SecondaryText)

                                HStack {
                                    Button { onBack?() } label: {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(canGoBack ? .white : .f1SecondaryText.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                            .background(Circle().fill(Color("f1Surface")))
                                            .overlay(Circle().stroke(Color.f1Border, lineWidth: 1))
                                    }
                                    .disabled(!canGoBack)

                                    Spacer()

                                    Button { onForward?() } label: {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(canGoForward ? .white : .f1SecondaryText.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                            .background(Circle().fill(Color("f1Surface")))
                                            .overlay(Circle().stroke(Color.f1Border, lineWidth: 1))
                                    }
                                    .disabled(!canGoForward)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }

                        RaceHeaderView(race: race)
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.f1Divider)
                        .frame(height: 1)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    
                    // Session rows
                    VStack(spacing: 0) {
                        ForEach(Array(race.sessions.enumerated()), id: \.offset) { _, session in
                            AppSessionRowView(session: session, isCanceled: race.isCanceled)
                        }
                    }

                    // Race results (when any session completed)
                    if !raceResults.isEmpty {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)
                            .padding(.top, 10)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)

                        RaceResultsView(
                            results: raceResults,
                            displayType: resultsDisplayType,
                            sessionName: resultsSessionName
                        )
                    }

                    // Divider before weather
                    if isWeatherAvailable {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)
                            .padding(.top, 10)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }

                    // Weather (only available within 5 days of race weekend)
                    if isWeatherAvailable {
                        WeatherSectionView(state: weatherState, temperatureUnit: settings.temperatureUnit)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }

                    // Divider before circuit
                    if circuitInfo != nil {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)
                            .padding(.top, 10)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }

                    // Circuit info
                    if let info = circuitInfo {
                        CircuitInfoView(circuit: info, raceName: race.name)
                            .padding(.top, 20)
                            .padding(.bottom, 24)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                }
            }
            .background(Color("f1Background"))
            .tint(.f1Red)
            .overlay(GeometryReader { geo in Color.clear.preference(key: ScreenWidthKey.self, value: geo.size.width) })
            .onPreferenceChange(ScreenWidthKey.self) { screenWidth = $0 }
            .overlay(alignment: .leading) {
                Color.clear
                    .frame(width: screenWidth / 10)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                guard abs(value.translation.width) > abs(value.translation.height),
                                      value.translation.width > 50, canGoBack else { return }
                                onBack?()
                            }
                    )
            }
            .overlay(alignment: .trailing) {
                Color.clear
                    .frame(width: screenWidth / 10)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                guard abs(value.translation.width) > abs(value.translation.height),
                                      value.translation.width < -50, canGoForward else { return }
                                onForward?()
                            }
                    )
            }
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
            .navigationDestination(for: Session.self) { session in
                SessionResultsLoader(session: session)
            }
            .onChange(of: deepLinkedSession) { _, session in
                guard let session else { return }
                navigationPath = NavigationPath()
                navigationPath.append(session)
                deepLinkedSession = nil
            }
        }
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

        // If whole weekend is done, show GP results; otherwise show latest completed session
        let targetSession: Session
        if race.isCompleted,
           let gp = completedSessions.last(where: { $0.name == "GRAND PRIX" }) {
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
        case "SPRINT QUALI": return .sprintTiming
        default: return .timing
        }
    }
}

// MARK: - Screen Width Preference Key

private struct ScreenWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 393
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
