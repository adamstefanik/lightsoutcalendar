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
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var isVisible: Bool = false
    
    private var isPlaying: Bool {
        isVisible && scenePhase == .active
    }
    
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
                                .fill(Color.f1Carbon)
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
                GeometryReader { geo in
                    let cardWidth = (geo.size.width - 8 * 2) / 3
                    HStack(spacing: 8) {
                        ForEach(forecasts) { forecast in
                            WeatherDayCard(forecast: forecast, temperatureUnit: temperatureUnit, isPlaying: isPlaying)
                                .frame(width: cardWidth)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 95)
                
            case .error:
                Text("Weather unavailable")
                    .font(.system(size: 12))
                    .foregroundColor(.f1SecondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            }
        }
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }
    // MARK: - Day Card
    
    private struct WeatherDayCard: View {
        let forecast: DayForecast
        let temperatureUnit: TemperatureUnit
        let isPlaying: Bool
        
        private func convertTemp(_ celsius: Int) -> Int {
            temperatureUnit == .fahrenheit ? Int(Double(celsius) * 9.0 / 5.0 + 32) : celsius
        }
        
        private var airTempDisplay: String { "\(convertTemp(forecast.tempHigh))°" }
        
        private var trackTempDisplay: String {
            guard let t = forecast.trackTemp else { return "N/A" }
            return "\(convertTemp(t))°"
        }
        
        private var windDisplay: String {
            guard let speed = forecast.windSpeed else { return "N/A" }
            return "\(speed) km/h"
        }
        
        var body: some View {
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    Text(forecast.dayLabel)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.f1Text)
                        .lineLimit(1)

                    LottieView(fileName: forecast.condition.lottieFileName, isPlaying: isPlaying)
                        .frame(width: 30, height: 30)
                        .clipped()

                    Text(airTempDisplay)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.f1Text)
                        .lineLimit(1)
                }

                VStack(alignment: .leading, spacing: 6) {
                    WeatherDetailRow(label: "TRACK:", value: trackTempDisplay)
                    WeatherDetailRow(label: "WIND:", value: windDisplay)
                    WeatherDetailRow(label: "RAIN:", value: "\(forecast.rainChance)%")
                }
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.f1Carbon)
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
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.f1Text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
    }
}
