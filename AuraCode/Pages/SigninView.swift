import SwiftUI
import GoogleSignInSwift

struct SigninView: View {
    var geo: GeometryProxy
    var viewModel: AuthenticationViewModel
    @Binding var showSignInView: Bool
    @Binding var showOnboarding: Bool

    var body: some View {
        VStack {
            Text("Aura Code")
                .font(.title)
                .bold()

            AsyncImage(url: URL(string: "https://preview.redd.it/how-super-saiyan-blue...")) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
                    .offset(x: -25)
            } placeholder: {
                ProgressView()
            }

            VStack {
                Text("Sign In")
                    .font(.title)
                    .fontWeight(.semibold)

                GoogleSignInButton(
                    viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)
                ) {
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
                .frame(width: geo.size.width / 3)
                .padding()

                // the below will crash because there isnt a logged in thing 
//                DividerWithOr(width: geo.size.width / 4)
//
//                Button {
//                    viewModel.signInAsGuest()
//                    showSignInView = false
//                } label: {
//                    Label("Continue as Guest", systemImage: "person.fill")
//                }
//                .padding()
//                .background(.gray.opacity(0.2))
//                .cornerRadius(10)
            }
        }
    }
}

struct DividerWithOr: View {
    var width: CGFloat
    var body: some View {
        HStack {
            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
            Text("or")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
        }
        .frame(width: width)
    }
}

