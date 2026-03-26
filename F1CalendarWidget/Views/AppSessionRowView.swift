import SwiftUI

struct AppSessionRowView: View {
    let session: Session
    var isCanceled: Bool = false

    private var isCompleted: Bool {
        guard let end = session.endDate else { return false }
        return end < Date()
    }

    private var hasResults: Bool {
        isCompleted && session.sessionKey != nil && !isCanceled
    }

    var body: some View {
        Group {
            if hasResults {
                NavigationLink {
                    SessionResultsLoader(session: session)
                } label: {
                    sessionContent
                }
            } else {
                sessionContent
            }
        }
    }

    private var sessionContent: some View {
        HStack(spacing: 0) {
            Text(session.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.f1Text)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isCanceled {
                Text("CANCELED")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.f1SecondaryText)
                    .frame(width: 95, alignment: .leading)
            } else if isCompleted {
                HStack(spacing: 4) {
                    Text("COMPLETED")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.f1SecondaryText)
                    if hasResults {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.f1SecondaryText)
                    }
                }
                .frame(width: 95, alignment: .leading)
            } else {
                Text(session.day)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.f1SecondaryText)
                    .frame(width: 95, alignment: .leading)
            }

            if session.isLive {
                Text("LIVE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color.f1Red))
                    .frame(width: 100, alignment: .trailing)
            } else {
                Text(session.time)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.f1Text)
                    .frame(width: 100, alignment: .trailing)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 10)
        .opacity(isCanceled ? 0.3 : (isCompleted ? 0.45 : 1.0))
    }
}

// MARK: - Session Results Loader

struct SessionResultsLoader: View {
    let session: Session
    @State private var results: [DriverResult] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                        .tint(.f1Red)
                    Text("Loading results...")
                        .font(.system(size: 12))
                        .foregroundColor(.f1SecondaryText)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("f1Background"))
            } else if results.isEmpty {
                VStack {
                    Text("No results available")
                        .font(.system(size: 14))
                        .foregroundColor(.f1SecondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("f1Background"))
            } else {
                SessionResultsView(title: session.name, results: results)
            }
        }
        .task {
            guard let key = session.sessionKey else {
                isLoading = false
                return
            }
            results = await F1APIService.shared.fetchResults(for: key)
            isLoading = false
        }
    }
}

// MARK: - Previews

#Preview("Upcoming") {
    VStack(spacing: 0) {
        ForEach(Array(F1Calendar.fallbackRaces[2].sessions.enumerated()), id: \.offset) { _, session in
            AppSessionRowView(session: session)
        }
    }
    .background(Color("f1Background"))
    .preferredColorScheme(.dark)
}

#Preview("Live FP1") {
    VStack(spacing: 0) {
        ForEach(Array(Race.previewLive.sessions.enumerated()), id: \.offset) { _, session in
            AppSessionRowView(session: session)
        }
    }
    .background(Color("f1Background"))
    .preferredColorScheme(.dark)
}
