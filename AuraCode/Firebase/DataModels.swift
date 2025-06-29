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
    var learningStyle: String
    var lessonSizing: String
    var grade: String
}

struct LessonOverview: Codable, Equatable, Hashable {
    var title: String
    var objective: String
    var key_concepts: [String]
    var difficulty: Int
    var estimated_time: Int
}

struct LearningPath: Identifiable, Codable, Equatable, Hashable {
    var id: String? = nil
    var name: String
    var lessons: [LessonOverview]
}

struct Lesson: Codable, Equatable, Hashable {
    var modules: [LessonModule]
}

struct LessonModule: Codable, Equatable, Hashable {
    var code: String?
    var expected_output : String?
    var content: String
    var options: [MCQOption]?
    var screen_type: String
    var question: Bool
}

struct MCQOption: Codable, Equatable, Hashable {
    var is_correct: Bool
    var option: String
}


class LearningPathViewModel: ObservableObject {
    @Published var learningPaths: [LearningPath] = []
    var listener: ListenerRegistration?

    func startListening(uid: String) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").document(uid).collection("learning_paths")

        listener = collectionRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening: \(error)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            self.learningPaths = documents.compactMap { doc in
                do {
                    var path = try doc.data(as: LearningPath.self)
                    path.id = doc.documentID
                    return path
                } catch {
                    print("Decoding error: \(error)")
                    return nil
                }
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
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
    
    func getCurrentUser() -> User? {
        Auth.auth().currentUser
    }

    
    func loadCurrentUser() {
        guard let user = Auth.auth().currentUser else { return }
        
        userEmail = user.email
        userName = user.displayName
        userImage = user.photoURL?.absoluteString
        isGuestUser = false
        uid = user.uid
    }
    
    
    func checkUserDocument(completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func createUserNode(grade: String, learningStyle: String, lessonSizing: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let newUser = Personal(
            userID: userID,
            aura: 0,
            learningStyle: learningStyle,
            lessonSizing: lessonSizing,
            grade: grade
        )
        
        do {
            let data = try Firestore.Encoder().encode(newUser)
            let userRef = Firestore.firestore().collection("users").document(userID)
            userRef.setData(data) { error in
                if let error = error {
                    print("Error creating user document: \(error)")
                } else {
                    print("User onboarding complete and document created.")
                }
            }
        } catch {
            print("Encoding error: \(error)")
        }
    }
    
    func signOutUser(onSuccess: () -> Void) {
        do {
            try AuthenticationManager.shared.signOut()
            userEmail = nil
            userName = nil
            userImage = nil
            userType = nil
            uid = nil
            onSuccess()
        } catch {
            print("error with guest signout")
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
    func signInGoogleAndCheckIfNew() async throws -> Bool {
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
        self.userType = "Basic"
        
        let userID = authResult.uid
        let db = Firestore.firestore()
        let doc = try await db.collection("users").document(userID).getDocument()
        return !doc.exists
    }
}
