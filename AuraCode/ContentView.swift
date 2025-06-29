import SwiftUI
import AppKit
import FirebaseFirestore

struct ContentView: View {
    @State var code = "a = 32"
    @AppStorage("aura") var aura = 0
    @AppStorage("userEmail") var userEmail: String?
    @AppStorage("userName") var userName: String?
    @AppStorage("userImage") var userImage: String?
    @AppStorage("userType") var userType: String?
    @AppStorage("uid") var uid: String?
    
    @State var showSignInView = true
    @State var showOnboarding = false
    var viewModel = AuthenticationViewModel()

    var body: some View {
        GeometryReader { geo in

        NavigationStack {
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
                        aura: $aura,
                        viewModel: viewModel,
                        showSignInView: $showSignInView
                    )
                    .onAppear {
                        if let uid = uid {
                            let db = Firestore.firestore()
                            db.collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
                                if let error = error {
                                    print("Error fetching document: \(error)")
                                    return
                                }

                                guard let document = documentSnapshot, document.exists else {
                                    print("Document does not exist")
                                    return
                                }

                                if let auraValue = document.get("aura") as? Int {
                                    aura = auraValue
                                }
                            }
                        }

                    }
                    
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

        }

    }
}

