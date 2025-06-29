import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}


final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}


func sendAuthorizedRequest(
    endpoint: String,
    body: [String: Any],
    method: String = "POST"
) async throws -> (Data, URLResponse) {
    guard let user = Auth.auth().currentUser else {
        throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
    }
    let token = try await user.getIDToken()
    
    guard let url = URL(string: "http://\(user.email == "keshavrshah@gmail.com" ? "192.168.1.68" : "localhost"):8000\(endpoint)") else {
            throw URLError(.badURL)
        }
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    return try await URLSession.shared.data(for: request)
}
