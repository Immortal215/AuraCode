import SwiftUI

struct LearningPathOverview: View {
    let learningPath: LearningPath
    @State var code: String = ""
    var viewModel: AuthenticationViewModel
    @Binding var aura: Int
    @Binding var showSignInView: Bool

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text(learningPath.name)
                            .font(.largeTitle)
                            .bold()
                        var ll = Double(learningPath.lessons.count)
                        var lc = Double(learningPath.completed_lessons.count)
                        ProgressView("\(Int(lc))/\(Int(ll))", value: lc, total: ll)
                            .padding()
                    }
                    Text("Lessons")
                        .font(.title2)
                        .bold()

                    VStack(spacing: 12) {
                        ForEach(Array(learningPath.lessons.enumerated()), id: \.element.title) { index, lesson in
                            let isCompleted = learningPath.completed_lessons.contains(index)

                            Group {
                                if isCompleted {
                                    lessonCard(lesson: lesson, isCompleted: true)
                                } else {
                                    NavigationLink(
                                        destination: LessonView(
                                            code: $code,
                                            lesson: lesson,
                                            lessonIndex: index,
                                            learningPathId: learningPath.id ?? "unknown",
                                            viewModel: viewModel,
                                            learningPathDoc: learningPath,
                                            showSignInView: $showSignInView,
                                            aura: $aura
                                        )
                                    ) {
                                        lessonCard(lesson: lesson, isCompleted: false)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(width: geo.size.width)
            }
        }
    }

    @ViewBuilder
    func lessonCard(lesson: LessonOverview, isCompleted: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline)
                    .foregroundColor(isCompleted ? .gray : .primary)

                Text(lesson.objective)
                    .font(.subheadline)
                    .foregroundColor(isCompleted ? .gray : .secondary)
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(isCompleted ? Color.systemGray6 : .systemBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
        .opacity(isCompleted ? 0.6 : 1.0)
    }
}
