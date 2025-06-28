import SwiftUI

struct OnboardingView: View {
    @State var selectedGrade = "9"
    @State var selectedLearningStyle = "Visual"
    @State var selectedLessonSize = "Microlearn"
    @Environment(\.dismiss) var dismiss

    var onComplete: (_ grade: String, _ learningStyle: String, _ lessonSize: String) -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("Let's personalize your learning!")
                .font(.largeTitle.bold())
                .padding(.top)
            VStack(alignment: .leading) {
                
                Text("What grade are you in?")
                    .font(.headline)
                
                Picker("Grade", selection: $selectedGrade) {
                    ForEach(Array(1...12), id: \.self) { grade in
                        Text("Grade \(grade)").tag(String(grade))
                    }
                }
                .pickerStyle(.menu)
            }

            VStack(alignment: .leading) {
                Text("Choose your learning style:")
                    .font(.headline)
                Picker("Learning Style", selection: $selectedLearningStyle) {
                    ForEach(["Visual", "Auditory", "Kinesthetic"], id: \.self) { style in
                        Text(style).tag(style)
                    }
                }
                .pickerStyle(.menu)
            }

            VStack(alignment: .leading) {
                Text("How do you want to learn?")
                    .font(.headline)
                Picker("Lesson Type", selection: $selectedLessonSize) {
                    Text("Microlearn").tag("Microlearn")
                    Text("Traditional").tag("Traditional")
                }
                .pickerStyle(.segmented)
            }

            Spacer()

            Button {
                onComplete(selectedGrade, selectedLearningStyle.lowercased(), selectedLessonSize.lowercased())
                dismiss()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.bottom)
        }
        .padding()
    }
}
