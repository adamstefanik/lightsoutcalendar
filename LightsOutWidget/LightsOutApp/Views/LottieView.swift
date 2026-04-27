import SwiftUI
import Lottie

#if os(iOS)
struct LottieView: UIViewRepresentable {
    let fileName: String
    var loopMode: LottieLoopMode = .loop
    var isPlaying: Bool = true

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.clipsToBounds = true

        let animationView = LottieAnimationView(name: fileName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        animationView.setContentHuggingPriority(.defaultLow, for: .vertical)
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        if isPlaying { animationView.play() }

        context.coordinator.animationView = animationView
        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let view = context.coordinator.animationView else { return }
        if isPlaying, !view.isAnimationPlaying {
            view.play()
        } else if !isPlaying, view.isAnimationPlaying {
            view.pause()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        weak var animationView: LottieAnimationView?
    }
}
#elseif os(macOS)
struct LottieView: NSViewRepresentable {
    let fileName: String
    var loopMode: LottieLoopMode = .loop
    var isPlaying: Bool = true

    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.masksToBounds = true

        let animationView = LottieAnimationView(name: fileName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        if isPlaying { animationView.play() }

        context.coordinator.animationView = animationView
        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let view = context.coordinator.animationView else { return }
        if isPlaying, !view.isAnimationPlaying {
            view.play()
        } else if !isPlaying, view.isAnimationPlaying {
            view.pause()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        weak var animationView: LottieAnimationView?
    }
}
#endif
