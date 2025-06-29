import SwiftUI
import Firebase
import FirebaseFirestore

struct LessonView: View {
    @Binding var code: String
    let lesson: LessonOverview
    let lessonIndex: Int
    let learningPathId: String
    var viewModel : AuthenticationViewModel
    
    @State var isLoading = true
    @State var errorMessage: String?
    @State var lessonData: Lesson?
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if isLoading {
                    ProgressView("Loading lesson...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    HStack(spacing: 0) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(lesson.title)
                                    .font(.largeTitle).bold()
                                Text(lesson.objective)
                                    .font(.title3)
                                HStack {
                                    ChunkButton(color: .purple, symbol: .init(systemName: "square.on.square"))
                                    ChunkButton(color: .purple, symbol: .init(systemName: "square.on.square"))
                                    ChunkButton(color: .purple, symbol: .init(systemName: "square.on.square"))
                                }
                                if let lessonData = lessonData {
                                    Text("Lesson screen type: \(lessonData.screen_type)")
                                    if let options = lessonData.options {
                                        ForEach(options, id: \.option) { opt in
                                            Text("• \(opt.option)\(opt.is_correct ? " ✅" : "")")
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        Divider()
                        CodeEditorView(code: $code)
                            .padding()
                            .padding(.top, 50)
                            .frame(width: geo.size.width * 2/3)
                    }
                }

                if let error = errorMessage {
                    VStack(spacing: 12) {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await fetchLessonContent() }
                        }
                    }
                    .padding()
                    .background(Color(.darkGray).opacity(0.9))
                    .cornerRadius(12)
                }
            }
            .onAppear {
                guard let uid = viewModel.uid else {
                    errorMessage = "User not logged in"
                    isLoading = false
                    return
                }

                let db = Firestore.firestore()
                let lessonRef = db.collection("users")
                    .document(uid)
                    .collection("learning_paths")
                    .document(learningPathId)
                    .collection("modules")
                    .document(String(lessonIndex))

                lessonRef.getDocument { document, error in
                    if let error = error {
                        self.errorMessage = "Firestore error: \(error.localizedDescription)"
                        self.isLoading = false
                        return
                    }

                    if let document = document, document.exists,
                       let data = try? JSONSerialization.data(withJSONObject: document.data() ?? [:]),
                       let lesson = try? JSONDecoder().decode(Lesson.self, from: data) {
                        self.lessonData = lesson
                        self.code = lesson.code ?? ""
                        self.isLoading = false
                    } else {
                        Task {
                            await fetchLessonContent()
                        }
                    }
                }
            }
        }
    }

    func fetchLessonContent() async {
        isLoading = true
        errorMessage = nil
        
        let body: [String: Any] = [
            "lesson_index": lessonIndex,
            "learning_path_id": learningPathId
        ]
        
        do {
            let (data, response) = try await sendAuthorizedRequest(
                endpoint: "/create_lesson",
                body: body
            )
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                errorMessage = "Server error: \(response)"
                isLoading = false
                return
            }
            
            let decoded = try JSONDecoder().decode(Lesson.self, from: data)
            self.lessonData = decoded
            self.code = decoded.code ?? ""
            
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

