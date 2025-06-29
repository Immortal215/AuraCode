import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @Binding var code: String
    @Binding var aura: Int
    var viewModel: AuthenticationViewModel
    @Binding var showSignInView: Bool

    @State var showPopover = false
    @State var topicInput = ""
    @StateObject var pathViewModel = LearningPathViewModel()

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        SectionView(title: "My Learning Paths", subtitle: "Your learning paths") {
                            ForEach(pathViewModel.learningPaths) { path in
                                NavigationLink(destination: LearningPathOverview(learningPath: path, viewModel: viewModel, aura: $aura)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(path.name)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        
                                        Text("\(path.lessons.count) lessons")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 48)
                    .buttonStyle(.plain)
                    .onAppear {
                        if let uid = viewModel.uid {
                            pathViewModel.startListening(uid: uid)
                        }
                    }
                    .onDisappear {
                        pathViewModel.stopListening()
                    }
                }
            }
            .overlay {
                TopBarView(viewModel: viewModel, aura: $aura) {
                    viewModel.signOutUser {
                        showSignInView = true
                    }
                    
                    
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showPopover = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 56, height: 56)
                            .foregroundColor(.blue)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
        .popover(isPresented: $showPopover) {
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
    }

    func createLearningPath() async {
        guard let user = viewModel.getCurrentUser() else {
            print("No user logged in")
            return
        }

        do {
            
            let body: [String: Any] = ["topic": topicInput]

            let (data, response) = try await sendAuthorizedRequest(
                endpoint:  "/create_learning_path",
                body: body
            )
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                print("Server Error")
                return
            }
            
            if let result = String(data: data, encoding: .utf8) {
                code = result
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Lesson plan created successfully!")
                topicInput = ""
                showPopover = false
            } else {
                print("Server error: \(response)")
            }
        } catch {
            print("Token or network error: \(error.localizedDescription)")
        }
    }
}
