import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @Binding var code: String
    @Binding var aura: Int
    var viewModel: AuthenticationViewModel

    @State var showPopover = false
    @State var topicInput = ""
    @StateObject  var pathViewModel = LearningPathViewModel()
    @Binding var showSignInView : Bool 
    var body: some View {
        VStack(spacing: 0) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .padding(.top, 40)
                .padding(.bottom, 20)
                .frame(width: 160)
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    WelcomeHeader(viewModel: viewModel, showSignInView: $showSignInView)
                        .padding()
                    CourseGrid(paths: pathViewModel.learningPaths, viewModel: viewModel, aura: $aura, activate:{
                        showPopover.toggle() 
                    }, showSignInView: $showSignInView)
                    .padding()
                }
                .padding(.horizontal, 160)
                .padding(.top, 20)
            }
            .background(.systemBackground)
            Spacer(minLength: 100)
        }
        .background(.systemBackground)
        .onAppear(perform: startListening)
        .onDisappear(perform: stopListening)
        .popover(isPresented: $showPopover, content: popoverContent)
    }

    func popoverContent() -> some View {
        VStack(spacing: 20) {
            Text("What do you want to learn about?")
                .font(.headline)

            TextEditor(text: $topicInput)
                .frame(height: 120)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            Button("Generate Lesson Plan") {
                Task {
                    await createLearningPath()
                }
            }
            .padding(.vertical)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 320)
    }

    func startListening() {
        if let uid = viewModel.uid {
            pathViewModel.startListening(uid: uid)
        }
    }

    func stopListening() {
        pathViewModel.stopListening()
    }

    func createLearningPath() async {
        guard let _ = viewModel.getCurrentUser() else {
            print("No user logged in")
            return
        }

        do {
            let body: [String: Any] = ["topic": topicInput]
            let (data, response) = try await sendAuthorizedRequest(endpoint: "/create_learning_path", body: body)

            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                if let result = String(data: data, encoding: .utf8) {
                    code = result
                }
                topicInput = ""
                showPopover = false
                print("Lesson plan created successfully!")
            } else {
                print("Server error: \(response)")
            }
        } catch {
            print("Token or network error: \(error.localizedDescription)")
        }
    }
}
