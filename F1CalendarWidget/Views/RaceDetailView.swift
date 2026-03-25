import SwiftUI

struct RaceDetailView: View {
    let race: Race
    @StateObject private var settings = SettingsManager.shared

    @State private var weatherState: WeatherLoadState = .loading
    @State private var raceResults: [DriverResult] = []

    private var circuitInfo: CircuitInfo? {
        CircuitDatabase.info(for: race.shortName)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    RaceHeaderView(race: race)

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
                            AppSessionRowView(session: session)
                        }
                    }

                    // Race results (when completed)
                    if race.isCompleted && !raceResults.isEmpty {
                        Rectangle()
                            .fill(Color.f1Divider)
                            .frame(height: 1)

                        RaceResultsView(results: raceResults)
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.f1Divider)
                        .frame(height: 1)
                        .padding(.top, 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)

                    // Weather
                    WeatherSectionView(state: weatherState, temperatureUnit: settings.temperatureUnit)
                        .padding(.top, 10)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)

                    // Circuit info
                    if let info = circuitInfo {
                        CircuitInfoView(circuit: info)
                            .padding(.bottom, 24)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                }
            }
            .background(Color("f1Background"))
            .task {
                await loadWeather()
                await loadResults()
            }
        }
    }

    // MARK: - Weather Loading

    private func loadWeather() async {
        guard let info = circuitInfo else {
            weatherState = .error
            return
        }

        weatherState = .loading
        let forecasts = await WeatherService.shared.fetchForecast(
            latitude: info.latitude,
            longitude: info.longitude
        )

        if !forecasts.isEmpty {
            weatherState = .loaded(forecasts)
        } else {
            weatherState = .error
        }
    }

    // MARK: - Results Loading

    private func loadResults() async {
        guard race.isCompleted else { return }
        // Find the race session key from API sessions
        if let raceSession = race.apiSessions?.last {
            // Use session name hash as a placeholder session key
            // In production, session_key comes from the API
            let sessionKey = raceSession.name.hashValue
            raceResults = await F1APIService.shared.fetchResults(for: sessionKey)
        }
    }
}
