import SwiftUI

enum WeatherLoadState {
    case noApiKey
    case loading
    case loaded([DayForecast])
    case error
}

struct WeatherSectionView: View {
    let state: WeatherLoadState
    let temperatureUnit: TemperatureUnit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WEATHER")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.f1SecondaryText)

            switch state {
            case .noApiKey:
                Text("Set up in Settings")
                    .font(.system(size: 12))
                    .foregroundColor(.f1SecondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)

            case .loading:
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(.f1SecondaryText)
                    Spacer()
                }
                .padding(.vertical, 16)

            case .loaded(let forecasts):
                HStack(spacing: 10) {
                    ForEach(forecasts) { forecast in
                        WeatherDayBox(forecast: forecast, temperatureUnit: temperatureUnit)
                    }
                }

            case .error:
                Text("Weather unavailable")
                    .font(.system(size: 12))
                    .foregroundColor(.f1SecondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Day Box

private struct WeatherDayBox: View {
    let forecast: DayForecast
    let temperatureUnit: TemperatureUnit

    private var tempDisplay: String {
        let temp = temperatureUnit == .fahrenheit
            ? Int(Double(forecast.tempHigh) * 9.0 / 5.0 + 32)
            : forecast.tempHigh
        return "\(temp)°"
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Text(forecast.dayLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.f1Text)
                Text(forecast.condition.emoji)
                    .font(.system(size: 11))
                Text(tempDisplay)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.f1Text)
            }

            Text("rain \(forecast.rainChance)%")
                .font(.system(size: 10))
                .foregroundColor(.f1SecondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color("f1Surface"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.f1Border, lineWidth: 1)
        )
    }
}

// MARK: - Previews

#Preview("Loaded") {
    WeatherSectionView(
        state: .loaded([
            DayForecast(id: "FRI", dayLabel: "FRI", tempHigh: 38, tempLow: 28, condition: .clear, rainChance: 5),
            DayForecast(id: "SAT", dayLabel: "SAT", tempHigh: 36, tempLow: 27, condition: .cloudy, rainChance: 20),
            DayForecast(id: "SUN", dayLabel: "SUN", tempHigh: 35, tempLow: 26, condition: .rain, rainChance: 65),
        ]),
        temperatureUnit: .celsius
    )
    .background(Color("f1Background"))
    .preferredColorScheme(.dark)
}

#Preview("No API Key") {
    WeatherSectionView(state: .noApiKey, temperatureUnit: .celsius)
        .background(Color("f1Background"))
        .preferredColorScheme(.dark)
}
