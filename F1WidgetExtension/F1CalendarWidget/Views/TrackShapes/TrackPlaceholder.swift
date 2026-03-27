import SwiftUI

struct TrackPlaceholder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Simple oval track with a chicane
        path.move(to: CGPoint(x: w * 0.2, y: h * 0.15))
        path.addCurve(
            to: CGPoint(x: w * 0.8, y: h * 0.15),
            control1: CGPoint(x: w * 0.4, y: h * 0.0),
            control2: CGPoint(x: w * 0.6, y: h * 0.0)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.85, y: h * 0.5),
            control1: CGPoint(x: w * 0.95, y: h * 0.2),
            control2: CGPoint(x: w * 0.95, y: h * 0.4)
        )
        // Chicane
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.6))
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.7))
        path.addCurve(
            to: CGPoint(x: w * 0.2, y: h * 0.85),
            control1: CGPoint(x: w * 0.9, y: h * 0.9),
            control2: CGPoint(x: w * 0.4, y: h * 1.0)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.2, y: h * 0.15),
            control1: CGPoint(x: w * 0.05, y: h * 0.7),
            control2: CGPoint(x: w * 0.05, y: h * 0.3)
        )

        return path
    }
}

#Preview {
    TrackPlaceholder()
        .stroke(Color.f1Red, lineWidth: 2)
        .frame(width: 96, height: 96)
        .padding()
        .background(Color.f1Dark)
}
