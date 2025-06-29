import SwiftUI

struct CustomGoogleSignInButton: View {
    var geo: GeometryProxy
    var action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image("Google_Logo")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)

                Text("Sign In with Google")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding()
            .frame(width: geo.size.width * 0.3, height: 50)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black, lineWidth: 1) // black border
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1)  // scale down on press
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}
