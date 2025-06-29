import SwiftUI

struct LearningPathOverview: View {
    let learningPath: LearningPath  // Accept LearningPath object
    @State private var code: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(learningPath.name)
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 8)

            Text("Lessons:")
                .font(.title2)
                .bold()

            List(Array(learningPath.lessons.enumerated()), id: \.element.title) { index, lesson in
                NavigationLink(
                    destination: LessonView(
                        code: $code,
                        lesson: lesson,
                        lessonIndex: index,
                        learningPathId: learningPath.id ?? "unknown"
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text(lesson.title)
                            .font(.headline)
                        Text(lesson.objective)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }

        }
        .padding()
    }
}
