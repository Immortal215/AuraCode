import SwiftUI
import SwiftUIX

struct AuraCounterView: View {
    @Binding var aura: Int
    @State var hover = false
    @State var animateFlame = false
    @State var fireParticles: [FireParticle] = (0..<25).map { _ in FireParticle.random }
    @State var timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: CGFloat(aura / 10000))
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: aura / 10000)
            }
            .frame(width: 200, height: 200)
//                .fill(
//                    RadialGradient(
//                        gradient: Gradient(colors: [.red.opacity(0.3), .orange.opacity(0.1), .clear]),
//                        center: .center,
//                        startRadius: 40,
//                        endRadius: 180
//                    )
//                )
//                .stroke(.black, lineWidth: 3)

            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    for particle in fireParticles {
                        let x = particle.x * size.width
                        let y = particle.y * size.height
                        let transform = CGAffineTransform(translationX: x, y: y)
                            .scaledBy(x: particle.scale, y: particle.scale)

                        context.opacity = particle.opacity
                        context.transform = transform

                        context.draw(Image(systemName: "flame.fill"), at: .zero, anchor: .center)
                    }
                }
                .frame(width: 300, height: 200)
            }

            VStack(spacing: 10) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.orange)
                    .shadow(color: .red.opacity(0.6), radius: hover ? 30 : 15)
                    .scaleEffect(animateFlame ? 1.05 : 0.95)
                    .rotationEffect(.degrees(animateFlame ? -7 : 7))
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: animateFlame)

                Text("\(aura) Aura")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .orange.opacity(0.9), radius: hover ? 10 : 4)
            }
            .padding(40)
//            .background(
//                ZStack {
//                    BlurView(style: .hudWindow)
//                        .clipShape(RoundedRectangle(cornerRadius: 32))
//                }
//            )
            .shadow(color: .orange.opacity(0.3), radius: 30)
            .onHover { isHovering in
                withAnimation {
                    hover = isHovering
                }
            }
        }
        .onAppear {
            animateFlame = true
        }
        .onReceive(timer) { time in
            let date = time.timeIntervalSinceReferenceDate
            for i in fireParticles.indices {
                fireParticles[i].update(time: date)
            }
        }
    }
}


struct FireParticle {
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
    var speed: CGFloat
    var phase: Double

    mutating func update(time: TimeInterval) {
        y -= speed * 0.01
        opacity = max(0, 1 - Double(y))
        x += 0.005 * CGFloat(sin(time + phase))
        if y < -0.1 {
            self = FireParticle.random
        }
    }

    static var random: FireParticle {
        FireParticle(
            x: CGFloat.random(in: 0.3...0.7),
            y: CGFloat.random(in: 0.6...1.0),
            scale: CGFloat.random(in: 0.5...1.5),
            opacity: Double.random(in: 0.6...1),
            speed: CGFloat.random(in: 0.5...1.5),
            phase: Double.random(in: 0...2 * .pi)
        )
    }
}

struct BlurView: NSViewRepresentable {
    var style: NSVisualEffectView.Material

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = style
        view.blendingMode = .withinWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

