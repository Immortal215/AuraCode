import SwiftUI

struct SectionView<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            content
        }
    }
}

struct HomeCard: View {
    let title: String
    let progress: CGFloat?
    let accentColor: Color
    var hasFlare: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(accentColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(accentColor, lineWidth: 1.5)
                )
                .frame(height: 100)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(accentColor)
                if let progress = progress {
                    ProgressView(value: progress)
                        .accentColor(accentColor)
                        .scaleEffect(x: 1, y: 1.2, anchor: .center)
                } else if hasFlare {
                    Text("🔥 5 min challenge")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

