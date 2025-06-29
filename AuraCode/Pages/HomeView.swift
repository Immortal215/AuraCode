import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @Binding var code: String
    @Binding var aura: Int
    var viewModel: AuthenticationViewModel
    @AppStorage("userEmail") var userEmail: String?
    @AppStorage("userName") var userName: String?
    @AppStorage("userImage") var userImage: String?
    @AppStorage("userType") var userType: String?
    @AppStorage("uid") var uid: String?
    
    @State var showPopover = false
    @State var topicInput = ""
    @StateObject var pathViewModel = LearningPathViewModel()
    @Binding var showSignInView: Bool

    let colors: [Color] = [
        Color(red: 243/255, green: 205/255, blue: 205/255),
        Color(red: 197/255, green: 232/255, blue: 240/255),
        Color(red: 255/255, green: 242/255, blue: 204/255),
        Color(red: 222/255, green: 215/255, blue: 247/255),
        Color(red: 208/255, green: 234/255, blue: 215/255)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        ZStack(alignment: .topTrailing) {
                            HStack(spacing: 16) {
                                // Profile Picture
                                AsyncImage(url: URL(string: viewModel.getCurrentUser()?.photoURL?.absoluteString ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Welcome back,")
                                        .font(.system(size: 18))
                                        .foregroundColor(.gray)
                                    
                                    Text(viewModel.getCurrentUser()?.displayName ?? "User")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(Color(red: 111/255, green: 80/255, blue: 247/255))
                                }
                                
                                Spacer()
                                AuraCounterView(aura: $aura)
                                    .frame(width: 250, height: 150)
                                    .padding(45)
                            }
                            .padding()
                            
                            // Logout Button
                            Button {
                                do {
                                    try AuthenticationManager.shared.signOut()
                                    userEmail = nil
                                    userName = nil
                                    userImage = nil
                                    userType = nil
                                    uid = nil
                                    showSignInView = true
                                } catch {
                                    print("Error signing out: \(error.localizedDescription)")
                                }
                            } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                    .padding(10)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .padding([.top, .trailing], 12)
                        }
                        .background(.systemGray5)
                        .cornerRadius(20)
                        .shadow(color: .gray.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.top, 48)
                    .padding(.horizontal, 160)
                    
                    // Courses Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Learning Paths")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Click on a learning path to explore your lessons.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: 3), spacing: 24) {
                            ForEach(pathViewModel.learningPaths.prefix(8).indices, id: \.self) { index in
                                let path = pathViewModel.learningPaths[index]
                                NavigationLink(destination: LearningPathOverview(learningPath: path, viewModel: viewModel, aura: $aura, showSignInView: $showSignInView)) {
                                    VStack(spacing: 12) {
                                        Image(systemName: iconForPath(path.name))
                                            .font(.system(size: 28))
                                            .foregroundColor(.black)
                                        
                                        Text(path.name)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        
                                        Text("\(path.lessons.count) lessons")
                                            .font(.subheadline)
                                            .foregroundColor(.black.opacity(0.7))
                                    }
                                    .padding()
                                    .frame(height: 160)
                                    .frame(maxWidth: .infinity)
                                    .background(colors[index % colors.count])
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Add Class Button (always visible, consistent size)
                            Button(action: { showPopover.toggle() }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 28))
                                        .foregroundColor(.gray)
                                    Text("New Learning Path")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(height: 160)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 160)
                }
                .padding(.bottom, 100)
            }
            .background(.systemBackground)
            .onAppear(perform: startListening)
            .onDisappear(perform: stopListening)
            .popover(isPresented: $showPopover, content: popoverContent)
        }
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
                Task { await createLearningPath() }
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

    func iconForPath(_ name: String) -> String {
        let lowercased = name.lowercased()
        if lowercased.contains("math") || lowercased.contains("precalculus") { return "x.squareroot" }
        if lowercased.contains("science") { return "flask" }
        if lowercased.contains("spanish") || lowercased.contains("french") { return "character.book.closed" }
        if lowercased.contains("english") || lowercased.contains("literature") { return "book" }
        if lowercased.contains("government") || lowercased.contains("politics") { return "globe" }
        return "rectangle.stack.fill"
    }
}
