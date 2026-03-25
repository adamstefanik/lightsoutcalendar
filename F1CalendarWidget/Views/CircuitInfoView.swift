import SwiftUI

struct CircuitInfoView: View {
    let circuit: CircuitInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CIRCUIT")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.f1SecondaryText)

            VStack(alignment: .leading, spacing: 8) {
                Text(circuit.circuitId)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.f1Text)

                HStack(spacing: 16) {
                    InfoItem(label: "Length", value: circuit.length)
                    InfoItem(label: "Turns", value: "\(circuit.turns)")
                    InfoItem(label: "Lap Record", value: circuit.lapRecord)
                }

                Text("\(circuit.lapRecordHolder), \(circuit.lapRecordYear)")
                    .font(.system(size: 11))
                    .foregroundColor(.f1SecondaryText)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("f1Surface"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.f1Border, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
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
