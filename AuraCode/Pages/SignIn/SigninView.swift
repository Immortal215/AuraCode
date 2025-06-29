import SwiftUI
import GoogleSignInSwift

struct SigninView: View {
    var geo: GeometryProxy
    var viewModel: AuthenticationViewModel
    @Binding var showSignInView: Bool
    @Binding var showOnboarding: Bool

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 32) {
                Spacer()

                Image("Logo")
                       .resizable()
                       .scaledToFit()
                       .frame(width: 120)
                       .padding(.top, 40)
                       .padding(.bottom, 20)
                       .frame(maxWidth: .infinity, alignment: .center)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hey!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("Welcome Back!")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Sign in with Google to use AuraCode!")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.bottom, 14)
                }

                CustomGoogleSignInButton(geo: geo) {
                    Task {
                        do {
                            let needsOnboarding = try await viewModel.signInGoogleAndCheckIfNew()
                            if needsOnboarding {
                                showOnboarding = true
                            } else {
                                withAnimation(.smooth) {
                                    showSignInView = false
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 4) {
                    Text("By using AuraCode, you agree to our")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text("terms of use")
                        .font(.footnote)
                        .foregroundColor(Color.purple)
                        .underline()
                    Text("and")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text("privacy policy")
                        .font(.footnote)
                        .foregroundColor(Color.purple)
                        .underline()
                }

                Spacer()
            }
            .padding(.horizontal, 64)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.systemBackground)

            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Image("Graphic")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: geo.size.width * 0.45)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: geo.size.width, height: geo.size.height)
        .background(Color(.gray).opacity(0.1)
)
    }
}

