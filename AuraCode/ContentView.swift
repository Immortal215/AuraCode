import SwiftUI
import AppKit

struct ContentView: View {
    @State var code = "a = 32"
    @AppStorage("aura") var aura = 23
    @AppStorage("userEmail") var userEmail: String?
    @AppStorage("userName") var userName: String?
    @AppStorage("userImage") var userImage: String?
    @AppStorage("userType") var userType: String?
    @AppStorage("uid") var uid: String?

    @State var showSignInView = true
    @State var showOnboarding = false
    var viewModel = AuthenticationViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                if showSignInView {
                    SigninView(
                        geo: geo,
                        viewModel: viewModel,
                        showSignInView: $showSignInView,
                        showOnboarding: $showOnboarding
                    )
                } else {
                    HomeView(
                        code: $code,
                        aura: aura,
                        viewModel: viewModel,
                        showSignInView: $showSignInView
                    )
                }
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView { grade, learningStyle, lessonSize in
                viewModel.createUserNode(
                    grade: grade,
                    learningStyle: learningStyle,
                    lessonSizing: lessonSize
                )
                showOnboarding = false
                withAnimation(.smooth) {
                    showSignInView = false
                }
            }
            .frame(minWidth: 300, maxHeight: 400)
        }
        .onAppear {
            if viewModel.isGuestUser {
                viewModel.signOutUser {
                    showSignInView = true
                }
            } else if viewModel.userEmail != nil {
                showSignInView = false
            }

//            for family in NSFontManager.shared.availableFontFamilies {
//                print("Family: \(family)")
//            }
        }
    }
}
