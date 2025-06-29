import SwiftUI
import Firebase
import FirebaseFirestore

struct RichLessonTextView: View {
    let content: String

    var body: some View {
        let components = content.components(separatedBy: "```")
        VStack(alignment: .leading, spacing: 12) {
            ForEach(components.indices, id: \.self) { index in
                if index % 2 == 0 {
                    Text(.init(components[index]))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                } else {
                    CodeBlockView(code: components[index])
                }
            }
        }
    }

    struct CodeBlockView: View {
        let code: String
        @State var showCopyConfirmation = false

        var body: some View {
            ZStack(alignment: .topTrailing) {
                ScrollView(.horizontal) {
                    Text(code.replacingOccurrences(of: "python", with: "").replacingOccurrences(of: "javascript", with: ""))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(Color(.label))
                        .padding(12)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                        .contextMenu {
                            Button {
                                copyToClipboard()
                            } label: {
                                Text("Copy")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                }
                Button(action: {
                    copyToClipboard()
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14))
                        .padding(6)
                        .background(Color.purple.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())

                if showCopyConfirmation {
                    Text("Copied!")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .transition(.opacity)
                        .padding([.top, .trailing], 40)
                }
            }
            .animation(.easeInOut, value: showCopyConfirmation)
        }

        func copyToClipboard() {
         
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(code, forType: .string)

            withAnimation {
                showCopyConfirmation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showCopyConfirmation = false
                }
            }
        }
    }
}

struct LessonView: View {
    @Binding var code: String
    @State var output = ""
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
    @State var showFeedback = false
    @State var feedbackMessage = ""
    @State var isCorrect = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)
                        
                        Text("Loading lesson...")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("BackgroundColor").ignoresSafeArea())
                } else {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Button{
                                    if lessonData!.modules[currentIndex - 1].question == false {
                                        backToPrevious()
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Back")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.purple)
                                    )
                                }
                                .disabled(currentIndex == 0 || lessonData!.modules[currentIndex - 1].question == true )
                                .opacity(currentIndex == 0 || lessonData!.modules[currentIndex - 1].question == true ? 0.6 : 1.0)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 16))
                                    Text("\(aura)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.purple.opacity(0.9))
                                )
                            }
                            
                            if let lessonData = lessonData, currentIndex < lessonData.modules.count {
                                let module = lessonData.modules[currentIndex]
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Step \(currentIndex + 1) of \(lessonData.modules.count)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text(.init(module.screen_type.capitalized))
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.purple)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.purple.opacity(0.1))
                                            )
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(height: 8)
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.purple)
                                                .frame(width: geometry.size.width * CGFloat(currentIndex + 1) / CGFloat(lessonData.modules.count), height: 8)
                                                .animation(.easeInOut(duration: 0.3), value: currentIndex)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                                
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 20) {
                                        RichLessonTextView(content: module.content)
                                        
                                        if let options = module.options {
                                            VStack(spacing: 14) {
                                                ForEach(options.indices, id: \.self) { idx in
                                                    let opt = options[idx]
                                                    let isSelected = selectedOptionIndex == idx
                                                    let isCompleted = completedModules.contains(currentIndex)
                                                    
                                                    Button(action: {
                                                        guard !isCompleted else { return }
                                                        handleMCQSelection(optionIndex: idx, isCorrect: opt.is_correct)
                                                    }) {
                                                        HStack {
                                                            Text(opt.option)
                                                                .font(.system(size: 16, weight: .medium))
                                                                .foregroundColor(isSelected ? .white : .primary)
                                                                .multilineTextAlignment(.leading)
                                                            
                                                            Spacer()
                                                            
                                                            if isSelected && isCompleted {
                                                                Image(systemName: opt.is_correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                                    .foregroundColor(opt.is_correct ? .green : .red)
                                                                    .font(.system(size: 20))
                                                            }
                                                        }
                                                        .padding(16)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .fill(buttonBackgroundColor(isSelected: isSelected, isCorrect: opt.is_correct, isCompleted: isCompleted))
                                                        )
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                                        )
                                                    }
                                                    .disabled(isCompleted)
                                                }
                                            }
                                        } else if module.screen_type == "short_answer" {
                                            VStack(alignment: .leading, spacing: 16) {
                                                TextField("Type your answer here...", text: $shortAnswerText, axis: .vertical)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .lineLimit(3...6)
                                                    .disabled(completedModules.contains(currentIndex))
                                                
                                                if !completedModules.contains(currentIndex) {
                                                    Button("Submit Answer") {
                                                        handleShortAnswer()
                                                    }
                                                    .buttonStyle(PrimaryButtonStyle())
                                                    .disabled(shortAnswerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                                } else {
                                                    HStack {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.green)
                                                        Text("Answer submitted!")
                                                            .foregroundColor(.green)
                                                            .font(.system(size: 16, weight: .medium))
                                                    }
                                                }
                                            }
                                        } else if module.screen_type == "code" {
                                            VStack(spacing: 16) {
                                                if !completedModules.contains(currentIndex) {
                                                    Button("Run & Submit Code") {
                                                        handleCodeSubmission(expectedOutput: module.expected_output ?? "")
                                                    }
                                                    .buttonStyle(PrimaryButtonStyle())
                                                } else {
                                                    HStack {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.green)
                                                        Text("Code submitted successfully!")
                                                            .foregroundColor(.green)
                                                            .font(.system(size: 16, weight: .medium))
                                                    }
                                                }
                                                
                                                Text("Write your code in the editor on the right!")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)
                                                    .italic()
                                            }
                                        } else {
                                            if !completedModules.contains(currentIndex) {
                                                Button("Continue") {
                                                    handleTextModule()
                                                }
                                                .buttonStyle(PrimaryButtonStyle())
                                            } else {
                                                Button("Next") {
                                                    moveToNext()
                                                }
                                                .buttonStyle(SecondaryButtonStyle())
                                            }
                                        }
                                    }
                                }
                            } else {
                                VStack(spacing: 24) {
                                    VStack(spacing: 16) {
                                        Text("🎉")
                                            .font(.system(size: 60))
                                        
                                        Text("Lesson Complete!")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.purple)
                                        
                                        Text("Great job! You've mastered this lesson.")
                                            .font(.system(size: 18))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    VStack(spacing: 12) {
                                        HStack {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.system(size: 24))
                                            Text("Total Aura Points: \(aura)")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(.purple)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.yellow.opacity(0.1))
                                        )
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .padding(24)
                        .frame(width: geo.size.width / 3)
                        .background(Color("BackgroundColor"))
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1)
                        
                        CodeEditorView(code: $code, output: $output)
                            .padding(24)
                            .frame(width: geo.size.width * 2 / 3)
                            .background(Color("BackgroundColor"))
                    }
                    .background(Color("BackgroundColor").ignoresSafeArea())
                }

                if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 40))
                        
                        Text("Something went wrong")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(error)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button("Try Again") {
                            Task { await fetchLessonContent() }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                         //   .fill(.systemBackground)
                            .shadow(radius: 20)
                    )
                    .padding(40)
                }
                
                if showFeedback {
                    VStack(spacing: 12) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? .green : .red)
                            .font(.system(size: 30))
                        
                        Text(feedbackMessage)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isCorrect ? .green : .red)
                            .saturation(0.3)
                            .opacity(0.8)
                      //      .fill(Color(.systemBackground))
                            .shadow(radius: 10)
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .onAppear {
                loadLesson()
            }
        }
    }
    
    func buttonBackgroundColor(isSelected: Bool, isCorrect: Bool, isCompleted: Bool) -> Color {
        if isSelected && isCompleted {
            return isCorrect ? .green : .red
        } else if isSelected {
            return .purple
        } else {
            return Color.purple.opacity(0.1)
        }
    }
    
    func handleMCQSelection(optionIndex: Int, isCorrect: Bool) {
        selectedOptionIndex = optionIndex
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if isCorrect && !completedModules.contains(currentIndex) {
                completedModules.insert(currentIndex)
                aura += 10
                showFeedbackToast(message: "Correct! +10 aura", isCorrect: true)
            } else if isCorrect {
                showFeedbackToast(message: "Correct!", isCorrect: true)
            } else {
                showFeedbackToast(message: "Not quite right, try again!", isCorrect: false)
                selectedOptionIndex = nil
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                moveToNext()
            }
        }
    }
    
    func handleShortAnswer() {
        completedModules.insert(currentIndex)
        aura += 10
        showFeedbackToast(message: "Great answer! +10 aura", isCorrect: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            moveToNext()
            shortAnswerText = ""
        }
    }
    
    func handleCodeSubmission(expectedOutput: String) {
        let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExpected = expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedOutput == trimmedExpected {
            completedModules.insert(currentIndex)
            aura += 15
            showFeedbackToast(message: "Perfect! Code output matches! +15 aura", isCorrect: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                moveToNext()
            }
        } else {
            showFeedbackToast(message: "Output doesn't match expected result. Try again!", isCorrect: false)
        }
    }
    
    func handleTextModule() {
        if !completedModules.contains(currentIndex) {
            completedModules.insert(currentIndex)
            aura += 5
        }
        moveToNext()
    }
    
    func showFeedbackToast(message: String, isCorrect: Bool) {
        feedbackMessage = message
        self.isCorrect = isCorrect
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showFeedback = false
            }
        }
    }
    
    func loadLesson() {
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
                self.errorMessage = "Failed to load lesson: \(error.localizedDescription)"
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
            await MainActor.run {
                self.lessonData = decoded
                self.code = decoded.modules.first?.code ?? ""
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Network error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isPressed ? Color.purple.opacity(0.8) : Color.purple)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.purple)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

