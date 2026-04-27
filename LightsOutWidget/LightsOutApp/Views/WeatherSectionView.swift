import SwiftUI
import Lottie

enum WeatherLoadState {
    case loading
    case loaded([DayForecast])
    case error
}

struct WeatherSectionView: View {
    let state: WeatherLoadState
    let temperatureUnit: TemperatureUnit

    private var updatedLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "Updated \(formatter.string(from: Date()))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("TRACK CONDITIONS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.f1SecondaryText)

                Spacer()

                if case .loaded = state {
                    Text(updatedLabel)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.f1SecondaryText.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color("f1Surface"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.f1Border, lineWidth: 0.5)
                        )
                }
            }

            switch state {
            case .loading:
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(.f1SecondaryText)
                    Spacer()
                }
                .padding(.vertical, 16)

            case .loaded(let forecasts):
                HStack(spacing: 8) {
                    ForEach(forecasts) { forecast in
                        WeatherDayCard(forecast: forecast, temperatureUnit: temperatureUnit)
                            .containerRelativeFrame(.horizontal, count: 3, spacing: 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

            case .error:
                Text("Weather unavailable")
                    .font(.system(size: 12))
                    .foregroundColor(.f1SecondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            }
        }
    }
}

// MARK: - Day Card

private struct WeatherDayCard: View {
    let forecast: DayForecast
    let temperatureUnit: TemperatureUnit

    private func convertTemp(_ celsius: Int) -> Int {
        temperatureUnit == .fahrenheit ? Int(Double(celsius) * 9.0 / 5.0 + 32) : celsius
    }

    private var airTempDisplay: String { "\(convertTemp(forecast.tempHigh))°" }

    private var trackTempDisplay: String {
        guard let t = forecast.trackTemp else { return "N/A" }
        let prefix = forecast.isTrackTempEstimated ? "~" : ""
        return "\(prefix)\(convertTemp(t))°"
    }

    private var windDisplay: String {
        guard let speed = forecast.windSpeed, let dir = forecast.windDir else { return "N/A" }
        return "\(speed) km/h \(dir)"
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(forecast.dayLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.f1Text)

                LottieView(fileName: forecast.condition.lottieFileName)
                    .frame(width: 35, height: 35)
                    .clipped()

                Text(airTempDisplay)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.f1Text)
            }

            VStack(alignment: .leading, spacing: 6) {
                WeatherDetailRow(label: "TRACK TEMP", value: trackTempDisplay)
                WeatherDetailRow(label: "WIND:", value: windDisplay)
                WeatherDetailRow(label: "RAIN CHANCE", value: "\(forecast.rainChance)%")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("f1Surface"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.f1Border, lineWidth: 1)
        )
    }
}

private struct WeatherDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.f1SecondaryText)
                .lineLimit(1)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.f1Text)
                .lineLimit(1)
        }
    }
}

// MARK: - Previews

#Preview("3 Active") {
    WeatherSectionView(
        state: .loaded([
            DayForecast(id: "FRI", dayLabel: "FRI", tempHigh: 18, tempLow: 12, condition: .clear, rainChance: 5, trackTemp: 28, windSpeed: 12, windDir: "SE", isTrackTempEstimated: false),
            DayForecast(id: "SAT", dayLabel: "SAT", tempHigh: 16, tempLow: 11, condition: .cloudy, rainChance: 20, trackTemp: 21, windSpeed: 8, windDir: "NE", isTrackTempEstimated: false),
            DayForecast(id: "SUN", dayLabel: "SUN", tempHigh: 14, tempLow: 10, condition: .rain, rainChance: 65, trackTemp: 16, windSpeed: 22, windDir: "W", isTrackTempEstimated: false),
        ]),
        temperatureUnit: .celsius
    )
    .background(Color("f1Background"))
    .preferredColorScheme(.dark)
}

#Preview("2 Active") {
    WeatherSectionView(
        state: .loaded([
            DayForecast(id: "FRI", dayLabel: "FRI", tempHigh: 18, tempLow: 12, condition: .clear, rainChance: 5, trackTemp: 28, windSpeed: 12, windDir: "SE", isTrackTempEstimated: false),
            DayForecast(id: "SAT", dayLabel: "SAT", tempHigh: 16, tempLow: 11, condition: .cloudy, rainChance: 20, trackTemp: 21, windSpeed: 8, windDir: "NE", isTrackTempEstimated: false),
        ]),
        temperatureUnit: .celsius
    )
    .background(Color("f1Background"))
    .preferredColorScheme(.dark)
}

#Preview("1 Active") {
    WeatherSectionView(
        state: .loaded([
            DayForecast(id: "SUN", dayLabel: "SUN", tempHigh: 14, tempLow: 10, condition: .rain, rainChance: 65, trackTemp: 16, windSpeed: 22, windDir: "W", isTrackTempEstimated: true),
        ]),
        temperatureUnit: .celsius
    )
    
    .background(Color("f1Background"))
    .preferredColorScheme(.dark)
}

#Preview("Error") {
    WeatherSectionView(state: .error, temperatureUnit: .celsius)
        .background(Color("f1Background"))
        .preferredColorScheme(.dark)
}
