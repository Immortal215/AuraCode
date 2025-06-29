import FirebaseDatabase
import FirebaseCore
import FirebaseDatabaseInternal
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI
import FirebaseFirestore
import SwiftUIX

@main
struct AuraCodeApp: App {
    init() {
        FirebaseApp.configure()
        print("Firebase configured")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
           TextFormattingCommands()
        }
    }
}
