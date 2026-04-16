![Alt text](assets/ui-app.png)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg) ![iOS](https://img.shields.io/badge/iOS-17+-black.svg) ![WidgetKit](https://img.shields.io/badge/WidgetKit-supported-red.svg) ![License](https://img.shields.io/badge/license-MIT-blue.svg) 
# Lights Out Calendar

A sleek iOS app and widget for the 2026 season. Track every race weekend with live countdowns, full session schedules, results, weather forecasts, and circuit info.

## Features
**App**
- Full current season race calendar with detailed weekend schedule
- Live countdown to the next session
- Session results with fastest lap and driver standings
- Weather forecast for upcoming race weekends
- Circuit information with track maps
- Optional push notifications before sessions start
- Sprint weekend detection and adjusted schedules

**Widget**
- Medium and large Home Screen widgets
- Live countdown to the next race
- Full session schedule with local times
- Current session badge (live / upcoming)

## Widgets

<p align="left">
  <img src="assets/ui-widget.png" alt="F1 Calendar Widget" width="600"/>
</p>

## Data Sources

- **Sessions data** — [OpenF1 API](https://openf1.org) with 6-hour cache and built-in 2026 calendar fallback
- **Weather** — [OpenWeatherMap API](https://openweathermap.org) with per-circuit caching
- **All times** displayed in your local timezone

## Tech Stack

- **SwiftUI** + **WidgetKit**
- **Swift Concurrency** (async/await)
- **No external dependencies**

## Requirements

- Xcode 16+
- iOS 17+

## How to Run

1. Clone the repository
2. Open `LightsOutCalendar.xcodeproj` in Xcode
3. Build and run on a simulator or device
4. Add the widget to your Home Screen

## Structure
```
lightsoutcalendar/
├── LightsOutWidget/                    # Widget extension + app source
│   ├── LightsOutApp/
│   │   ├── Views/
│   │   │   ├── TrackShapes/
│   │   │   │   └── TrackPlaceholder.swift
│   │   │   ├── AppSessionRowView.swift
│   │   │   ├── CalendarRowView.swift
│   │   │   ├── CalendarView.swift
│   │   │   ├── CircuitInfoView.swift
│   │   │   ├── LottieView.swift
│   │   │   ├── RaceDetailView.swift
│   │   │   ├── RaceHeaderView.swift
│   │   │   ├── RaceResultsView.swift
│   │   │   ├── SessionResultsView.swift
│   │   │   ├── SettingsView.swift
│   │   │   ├── StandingsView.swift
│   │   │   └── WeatherSectionView.swift
│   │   ├── Lottie/                     # Animated weather icons
│   │   ├── ContentView.swift
│   │   └── LightsOutApp.swift
│   ├── Assets.xcassets/
│   ├── CircuitDatabase.swift
│   ├── CircuitInfo.swift
│   ├── DriverResult.swift
│   ├── RacingAPIService.swift
│   ├── RaceCalendar.swift
│   ├── AppColors.swift
│   ├── WidgetBundle.swift
│   ├── WidgetViews.swift
│   ├── NotificationManager.swift
│   ├── Race.swift
│   ├── SettingsManager.swift
│   ├── WeatherModels.swift
│   └── WeatherService.swift
├── LightsOutCalendar.xcodeproj
├── assets/
├── LICENSE
└── README.md
```

## License

Made with racing heart by <a href="https://github.com/adamstefanik">Adam Samuel Štefánik</a>. MIT — see [LICENSE](LICENSE) for details.
