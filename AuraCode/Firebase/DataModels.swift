import FirebaseDatabase
import FirebaseCore
import FirebaseDatabaseInternal
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI
import FirebaseFirestore

struct Personal: Codable, Equatable, Hashable {
    var userID: String
    var aura: Int
    var name: String
    var learningStyle: String
    var lessonSizing: String
}
@MainActor
final class AuthenticationViewModel: ObservableObject {
    @AppStorage("userEmail") var userEmail: String?
    @AppStorage("userName") var userName: String?
    @AppStorage("userImage") var userImage: String?
    @AppStorage("isGuestUser") var isGuestUser = true
    @AppStorage("userType") var userType: String?
    @AppStorage("uid") var uid: String?

    init() {
        userEmail = nil
        userName = nil
        userImage = nil
        isGuestUser = true
        userType = nil
        uid = nil
    }

    func loadCurrentUser() {
        guard let user = Auth.auth().currentUser else { return }

        userEmail = user.email
        userName = user.displayName
        userImage = user.photoURL?.absoluteString
        isGuestUser = false
        uid = user.uid
    }


    func createUserNodeIfNeeded() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User is not authenticated")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking user document: \(error)")
                return
            }
            if let document = document, !document.exists {
                let newUser = Personal(userID: userID, aura: 0, name: self.userName ?? "Anonymous", learningStyle: "visual", lessonSizing: "microlearn")
                do {
                    let data = try Firestore.Encoder().encode(newUser)
                    userRef.setData(data) { error in
                        if let error = error {
                            print("Error creating user document: \(error)")
                        } else {
                            print("User document created successfully")
                        }
                    }
                } catch {
                    print("Failed to encode user data: \(error)")
                }
            } else {
                print("User document already exists")
            }
        }
    }

    
    func signInAsGuest() {
        self.userName = "Guest Account"
        self.userEmail = "Explore!"
        self.userImage = nil
        self.isGuestUser = true
        self.userType = "Guest"
        self.uid = "None"
    }
    
    func getPresentingWindow() -> NSWindow? {
        NSApplication.shared.mainWindow
    }
    
    @MainActor
    func signInGoogle() async throws {
        guard let presentingWindow = getPresentingWindow() else {
            throw NSError(domain: "WindowError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No main window found"])
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase clientID"])
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingWindow)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let authResult = try await AuthenticationManager.shared.signInWithGoogle(idToken: idToken, accessToken: accessToken)
        
        self.userEmail = authResult.email
        self.userName = gidSignInResult.user.profile?.name ?? ""
        self.userImage = gidSignInResult.user.profile?.imageURL(withDimension: 200)?.absoluteString
        self.isGuestUser = false
        self.uid = authResult.uid
        
        self.createUserNodeIfNeeded()
        
        if let email = authResult.email {
            self.userType = "Basic"
        }
    }
}
