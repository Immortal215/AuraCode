import SwiftUI
import Firebase
import FirebaseFirestore

struct LessonView: View {
    @Binding var code: String
    let lesson: LessonOverview
    let lessonIndex: Int
    let learningPathId: String
    var viewModel: AuthenticationViewModel
    @Binding var aura: Int

    @State var isLoading = true
    @State var errorMessage: String?
    @State var lessonData: Lesson?
    @State var currentIndex: Int = 0
    @State var completedModules: Set<Int> = []
    @State var selectedOptionIndex: Int?
    @State var shortAnswerText: String = ""

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if isLoading {
                    ProgressView("Loading lesson...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("BackgroundColor").ignoresSafeArea())
                } else {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Button(action: backToPrevious) {
                                    Label("Back", systemImage: "chevron.left")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.purple)
                                        .cornerRadius(8)
                                }
                                Spacer()
                                Text("Aura Points: \(aura)")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                    .padding(8)
                                    .background(Color.purple.opacity(0.8))
                                    .cornerRadius(12)
                            }
                            
                            if let lessonData = lessonData, currentIndex < lessonData.modules.count {
                                let module = lessonData.modules[currentIndex]

                                Text("Step \(currentIndex + 1) of \(lessonData.modules.count)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(module.content)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.purple)
                                    .padding(.bottom, 10)

                                if let image = module.image {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.purple.opacity(0.1))
                                        .frame(height: 140)
                                        .overlay(
                                            Text("[Image: \(image)]")
                                                .italic()
                                                .foregroundColor(.purple.opacity(0.7))
                                        )
                                        .padding(.bottom, 10)
                                }

                                if let options = module.options {
                                    VStack(spacing: 12) {
                                        ForEach(options.indices, id: \.self) { idx in
                                            let opt = options[idx]
                                            Button(action: {
                                                selectedOptionIndex = idx
                                                if opt.is_correct && !completedModules.contains(currentIndex) {
                                                    completedModules.insert(currentIndex)
                                                    aura += 10
                                                    moveToNext()
                                                } else if opt.is_correct{
                                                    moveToNext()
                                                }
                                            }) {
                                                HStack {
                                                    Text(opt.option)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    if selectedOptionIndex == idx {
                                                        Image(systemName: opt.is_correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                            .foregroundColor(opt.is_correct ? .green : .red)
                                                            .scaleEffect(1.3)
                                                    }
                                                }
                                                .padding()
                                                .background(selectedOptionIndex == idx ? (opt.is_correct ? Color.green : Color.red) : Color.purple.opacity(0.8))
                                                .cornerRadius(12)
                                            }
                                        }
                                    }
                                }  else if module.screen_type == "short_answer" {
                                    VStack(alignment: .leading, spacing: 12) {
                                        TextField("Type your answer here...", text: $shortAnswerText)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(.vertical, 8)
                                        
                                        Button("Submit Answer") {
                                            completedModules.insert(currentIndex)
                                            aura += 10
                                            moveToNext()
                                            shortAnswerText = ""
                                            
                                        }
                                        .buttonStyle(PrimaryButtonStyle())
                                    }
//                                } else if module.screen_type == "code" {
//                                    VStack(spacing: 20) {
//                                        Button("Submit Code") {
//                                            // Example code validation - replace with actual logic
//                                            if code.contains("Hello, world!") && !completedModules.contains(currentIndex) {
//                                                completedModules.insert(currentIndex)
//                                                aura += 10
//                                                moveToNext()
//                                            }
//                                        }
//                                        .buttonStyle(PrimaryButtonStyle())
//                                        
//                                        Text("Write your code in the editor on the right!")
//                                            .font(.footnote)
//                                            .foregroundColor(.gray)
//                                    }
                                } else {
                                    Button("Next") {
                                        if !completedModules.contains(currentIndex) {
                                            completedModules.insert(currentIndex)
                                            aura += 5
                                        }
                                        moveToNext()
                                    }
                                    .buttonStyle(PrimaryButtonStyle())
                                }
                            } else {
                                VStack(spacing: 16) {
                                    Text("🎉 Lesson Complete! 🎉")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.purple)
                                    Text("You've earned \(aura) aura points!")
                                        .font(.title2)
                                        .foregroundColor(.yellow)
                                    Image(systemName: "star.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.yellow)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .padding()
                        .frame(width: geo.size.width / 3)
                        .background(Color("BackgroundColor"))
                        .cornerRadius(20)

                        Divider()

                        CodeEditorView(code: $code)
                            .padding()
                            .padding(.top, 50)
                            .frame(width: geo.size.width * 2 / 3)
                    }
                    .background(Color("BackgroundColor").ignoresSafeArea())
                }

                if let error = errorMessage {
                    VStack(spacing: 12) {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .bold()
                        Button("Retry") {
                            Task { await fetchLessonContent() }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                    .background(Color(.darkGray).opacity(0.9))
                    .cornerRadius(12)
                    .padding()
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
                        self.code = lesson.modules.first?.code ?? ""
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

    func backToPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
            selectedOptionIndex = nil
            if let lessonData = lessonData {
                code = lessonData.modules[currentIndex].code ?? code
            }
        }
    }

    func moveToNext() {
        if let lessonData = lessonData, currentIndex + 1 < lessonData.modules.count {
            currentIndex += 1
            selectedOptionIndex = nil
            code = lessonData.modules[currentIndex].code ?? code
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
            self.code = decoded.modules.first?.code ?? ""
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.purple.opacity(0.7) : Color.purple)
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
