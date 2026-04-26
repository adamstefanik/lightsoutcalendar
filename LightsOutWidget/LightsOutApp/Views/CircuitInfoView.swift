import SwiftUI

struct CircuitInfoView: View {
    let circuit: CircuitInfo
    var raceName: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CIRCUIT")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.f1SecondaryText)

            VStack(alignment: .leading, spacing: 8) {
                Text(raceName ?? circuit.circuitId)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.f1Text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                HStack(spacing: 16) {
                    InfoItem(label: "Length", value: circuit.length)
                    InfoItem(label: "Turns", value: "\(circuit.turns)")
                    InfoItem(label: "Lap Record", value: circuit.lapRecord)
                }

                Text("\(circuit.lapRecordHolder), \(String(circuit.lapRecordYear))")
                    .font(.system(size: 11))
                    .foregroundColor(.f1SecondaryText)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("f1Surface"))
            )
            .overlay(alignment: .bottomTrailing) {
                Image("formula_silhouette")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.f1Red)
                    .scaledToFit()
                    .frame(width: 130)
                    .opacity(0.4)
                    .padding(.trailing, 10)
                    .padding(.bottom, 8)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.f1Border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Info Item

private struct InfoItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.f1SecondaryText)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.f1Text)
        }
    }
}

// MARK: - Preview

#Preview {
    CircuitInfoView(circuit: CircuitInfo(
        circuitId: "Suzuka International Racing Course",
        length: "5.807 km",
        turns: 18,
        lapRecord: "1:30.983",
        lapRecordHolder: "Lewis Hamilton",
        lapRecordYear: 2019,
        latitude: 34.8431,
        longitude: 136.5407
    ))
    .background(Color("f1Background"))
    .preferredColorScheme(.dark)
}
