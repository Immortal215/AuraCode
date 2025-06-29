import SwiftUI

struct CourseGrid: View {
    let paths: [LearningPath]
    var viewModel: AuthenticationViewModel
    @Binding var aura: Int
    var activate: () -> Void
    @Binding var showSignInView : Bool
    let colors: [Color] = [
        Color(red: 243/255, green: 205/255, blue: 205/255),
        Color(red: 197/255, green: 232/255, blue: 240/255),
        Color(red: 222/255, green: 215/255, blue: 247/255),
        Color(red: 255/255, green: 242/255, blue: 204/255),
        Color(red: 255/255, green: 242/255, blue: 204/255),
        Color(red: 222/255, green: 215/255, blue: 247/255),
        Color(red: 243/255, green: 205/255, blue: 205/255),
        Color(red: 208/255, green: 234/255, blue: 215/255)
    ]
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(paths.indices, id: \.self) { index in
                NavigationLink(destination: LearningPathOverview(learningPath: paths[index], viewModel: viewModel, aura: $aura, showSignInView: $showSignInView)) {
                    CourseCard(
                        title: paths[index].name,
                        subtitle: "\(paths[index].lessons.count) lessons",
                        color: colors[index % colors.count],
                        path: paths[index]
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .shadow(color: .gray, radius: 5)
            }
            AddCourseCard(onTap: activate)
                .shadow(color: .gray, radius: 5)

        }
        .background(.systemBackground)
    }
}

struct CourseCard: View {
    let title: String
    let subtitle: String
    let color: Color
    var path : LearningPath
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressView("Progress", value: 50, total: 100)
                .tint(.purple)
                .foregroundStyle(.purple)
                .shadow(color: .purple, radius: 5)
               // .saturation(0.6)
              //  .progressViewStyle(LinearProgressViewStyle(tint: .purple))

            Spacer()

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(2)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: 600, maxHeight: 200)
        .background(color)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct AddCourseCard: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.gray)
                .padding(12)
                .background(.systemGray4)
                .clipShape(Circle())
        }
        .padding()
        .frame(width: 160, height: 160)
        .background(Color.systemGray6)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
