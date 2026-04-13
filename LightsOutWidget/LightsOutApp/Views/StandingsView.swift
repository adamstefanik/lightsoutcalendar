import SwiftUI

struct StandingsView: View {
    @State private var selectedStanding = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Standings", selection: $selectedStanding) {
                    Text("Drivers").tag(0)
                    Text("Constructors").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if selectedStanding == 0 {
                    driversPlaceholder
                } else {
                    constructorsPlaceholder
                }
            }
            .navigationTitle("Standings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
        }
    }

    private var driversPlaceholder: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "person.3.fill")
                .font(.system(size: 40))
                .foregroundStyle(.f1SecondaryText)
            Text("Driver Standings")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.f1Text)
            Text("Coming soon")
                .font(.system(size: 13))
                .foregroundStyle(.f1SecondaryText)
            Spacer()
        }
    }

    private var constructorsPlaceholder: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "building.2.fill")
                .font(.system(size: 40))
                .foregroundStyle(.f1SecondaryText)
            Text("Constructor Standings")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.f1Text)
            Text("Coming soon")
                .font(.system(size: 13))
                .foregroundStyle(.f1SecondaryText)
            Spacer()
        }
    }
}

#Preview {
    StandingsView()
        .preferredColorScheme(.dark)
}
