import SwiftUI

struct LessonView: View {
    @Binding var code: String
    let lesson: LessonOverview
    let lessonIndex: Int
    let learningPathId: String
    
    @State private var isLoading = true
    @State private var errorMessage: String?
    
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
                                Text("Lesson content loaded below.")
                                    .padding(.top)
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
                Task { await fetchLessonContent() }
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
                endpoint:  "/create_lesson",
                body: body
            )
            
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                errorMessage = "Server error: \(response)"
                isLoading = false
                return
            }
            
            if let result = String(data: data, encoding: .utf8) {
                code = result
            }
            
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
